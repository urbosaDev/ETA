const functions = require("firebase-functions");
const admin = require("firebase-admin");
admin.initializeApp();
const { onDocumentCreated } = require("firebase-functions/v2/firestore");
const { CloudTasksClient } = require("@google-cloud/tasks");
const client = new CloudTasksClient();

const PROJECT = 'what-s-your-eta-1805f';
const QUEUE = 'promise-queue';
const LOCATION = 'us-central1';
const FUNCTION_URL = 'https://us-central1-what-s-your-eta-1805f.cloudfunctions.net/handlePromiseTask';

// 약속 문서가 생성될 때마다 트리거
exports.schedulePromiseOnCreate = onDocumentCreated("promises/{docId}", async (event) => {
  const snap = event.data;
  const docId = snap.id;
  const data = snap.data();

  const oneHourBefore = new Date(data.time.toDate().getTime() - 60 * 60 * 1000); // 1시간 전
  const promiseTime = data.time.toDate();

  const queuePath = client.queuePath(PROJECT, LOCATION, QUEUE);

  const createTask = async (type, time) => {
    const task = {
      httpRequest: {
        httpMethod: "POST",
        url: FUNCTION_URL,
        headers: { "Content-Type": "application/json" },
        body: Buffer.from(JSON.stringify({ docId, type })).toString("base64"),
      },
      scheduleTime: {
        seconds: Math.floor(time.getTime() / 1000),
      },
    };
    return client.createTask({ parent: queuePath, task });
  };

  try {
    await createTask("notify1Hour", oneHourBefore);
    await createTask("notifyStart", promiseTime);
    console.log(`Tasks scheduled for promise ${docId}`);
  } catch (e) {
    console.error(`Failed to schedule tasks for promise ${docId}`, e);
  }
});
exports.handlePromiseTask = functions.https.onRequest(async (req, res) => {
  const { docId, type } = req.body;

  const db = admin.firestore();
  const docRef = db.collection("promises").doc(docId);
  const doc = await docRef.get();
  if (!doc.exists) return res.status(404).send("Document not found");

  const data = doc.data();
  const memberIds = data.memberIds || [];
  const groupId = data.groupId;
  const address = data.location?.address || '알 수 없음';
  const time = data.time?.toDate ? data.time.toDate() : new Date(data.time.seconds * 1000);
  const formattedTime = time.toLocaleString('ko-KR', { timeZone: 'Asia/Seoul' });

  // 공용 FCM 발송 함수
  const sendFcm = async (token, title, body) => {
    try {
      await admin.messaging().send({
        token,
        notification: { title, body },
      });
      console.log(`FCM sent to token ${token}`);
    } catch (error) {
      console.error(`FCM failed to token ${token}`, error);
    }
  };

  if (type === 'notify1Hour') {
  if (data.notify1HourScheduled) {
    console.log("Already processed notify1Hour for this doc");
    return res.status(200).send("Already handled");
  }
    for (const memberId of memberIds) {
      try {
        const userDoc = await db.collection("users").doc(memberId).get();
        const userData = userDoc.data();
        const tokens = userData?.fcmTokens || [];
        for (const token of tokens) {
          await sendFcm(token, `${data.name} 약속 1시간 전`, "준비해주세요!");
        }
      } catch (error) {
        console.error(`FCM error for ${memberId}`, error);
      }
    }

    // 그룹에 System 메시지 등록
    const message = {
      senderId: 'system',
      text: `⏰ 약속 1시간 전 알림!\n장소: ${address}, \n시간: ${formattedTime}\n약속장소에 도착 후 위치공유버튼을 눌러주세요`,
      sentAt: new Date(),
      type: 'system',
      readBy: [],
    };

    await db.collection("groups").doc(groupId).collection("messages").add(message);
    await docRef.update({ notify1HourScheduled: true });
    return res.status(200).send("1시간 전 알림 처리 완료");
  }

    if (type === 'notifyStart') {
          if (data.notifyStartScheduled) {
    console.log("Already processed notifyStart for this doc");
    return res.status(200).send("Already handled");
  }
    const arriveUserIds = data.arriveUserIds || [];
    const arriveNames = [];
    const lateNames = [];

    for (const uid of memberIds) {
      const userDoc = await db.collection("users").doc(uid).get();
      const userData = userDoc.data();
      if (!userData?.name) continue;

      // 도착/지각 이름 정리
      if (arriveUserIds.includes(uid)) {
        arriveNames.push(userData.name);
      } else {
        lateNames.push(userData.name);
      }

      // 공용 메시지 내용 → 전원에게 동일하게 발송
      const tokens = userData?.fcmTokens || [];
      for (const token of tokens) {
        await sendFcm(
          token,
          `${data.name} 약속 시작!`,
          `지금 약속 시간이에요!\n장소: ${address}`
        );
      }
    }

    const msg =
      `🕒 약속 시간이 되었습니다!\n장소: ${address}, \n시간: ${formattedTime}\n` +
      `✅ 도착: ${arriveNames.length ? arriveNames.join(', ') : '없음'}\n` +
      `🚫 미도착: ${lateNames.length ? lateNames.join(', ') : '없음'}`;

    await db.collection("groups").doc(groupId).collection("messages").add({
      senderId: 'system',
      text: msg,
      sentAt: new Date(),
      type: 'system',
      readBy: [],
    });

    await docRef.update({ notifyStartScheduled: true });
    return res.status(200).send("약속 시작 알림 처리 완료");
  }
  return res.status(400).send("Unknown task type");
});