const { onSchedule } = require("firebase-functions/v2/scheduler");
const { initializeApp } = require("firebase-admin/app");
const { getFirestore } = require("firebase-admin/firestore");
const { getMessaging } = require("firebase-admin/messaging");

initializeApp();

const db = getFirestore();

// 10분마다 실행 → 1시간 전 약속 알림
exports.scheduledPromiseOneHourReminder = onSchedule("every 10 minutes", async (event) => {
  const now = new Date();
  const oneHourFromNowStart = new Date(now.getTime() + 60 * 60 * 1000 - 10 * 60 * 1000);
  const oneHourFromNowEnd = new Date(now.getTime() + 60 * 60 * 1000 + 10 * 60 * 1000);

  const snapshot = await db.collection("promises")
    .where("time", ">=", oneHourFromNowStart)
    .where("time", "<=", oneHourFromNowEnd)
    .where("notify1HourScheduled", "==", false)
    .get();

  console.log(`Found ${snapshot.size} promises to notify.`);

  await Promise.all(snapshot.docs.map(async (doc) => {
    const data = doc.data();
    const memberIds = data.memberIds || [];

    for (const memberId of memberIds) {
      try {
        const userDoc = await db.collection("users").doc(memberId).get();
        const userData = userDoc.data();
        const tokens = userData?.fcmTokens || [];

        for (const token of tokens) {
          await sendFcm(token, `${data.name} 약속 1시간 전`, "준비해주세요!");
        }
      } catch (error) {
        console.error(`Failed to send FCM to user ${memberId}`, error);
      }
    }

    // System 메시지 먼저 저장
    try {
      const time = data.time?.toDate ? data.time.toDate() : new Date(data.time.seconds * 1000);
      const formattedTime = time.toLocaleString('ko-KR', { timeZone: 'Asia/Seoul' });
      const address = data.location?.address || '알 수 없음';

      const message = {
        senderId: 'system',
        text: `약속 1시간 전 알림! 약속 장소: ${address}, 시간: ${formattedTime} \n벌칙제안 및 투표를 진행해주세요.`,
        sentAt: new Date(),
        type: 'system',
        readBy: [],
      };

      await db
      .collection("promises")
      .doc(doc.id)
      .collection("messages")
      .add(message);

      console.log(`System message (1hr) sent for promise ${doc.id}`);
    } catch (error) {
      console.error(`Failed to send System message (1hr) for promise ${doc.id}`, error);
    }

    await doc.ref.update({
      notify1HourScheduled: true,
    });
  }));
});

// 5분마다 실행 → 약속 시작 알림
exports.scheduledPromiseStartReminder = onSchedule("every 5 minutes", async (event) => {
  const now = new Date();
  const startRange = new Date(now.getTime() - 2.5 * 60 * 1000);
  const endRange = new Date(now.getTime() + 2.5 * 60 * 1000);

  const snapshot = await db.collection("promises")
    .where("time", ">=", startRange)
    .where("time", "<=", endRange)
    .where("notifyStartScheduled", "==", false)
    .get();

  console.log(`Found ${snapshot.size} promises to notify for START.`);

  await Promise.all(snapshot.docs.map(async (doc) => {
    const data = doc.data();
    const memberIds = data.memberIds || [];
    const address = data.location?.address || '알 수 없음';
    const time = data.time?.toDate ? data.time.toDate() : new Date(data.time.seconds * 1000);
    const formattedTime = time.toLocaleString('ko-KR', { timeZone: 'Asia/Seoul' });

    try {
      // 도착한 사람들 name 가져오기
      const arriveUserIds = data.arriveUserIds || [];
      const arriveUserNames = [];

      for (const uid of arriveUserIds) {
        const userDoc = await db.collection("users").doc(uid).get();
        const userData = userDoc.data();
        if (userData?.name) {
          arriveUserNames.push(userData.name);
        }
      }

      // 벌칙 대상자 (memberIds - arriveUserIds)
      const lateUserIds = memberIds.filter(uid => !arriveUserIds.includes(uid));
      const lateUserNames = [];

      for (const uid of lateUserIds) {
        const userDoc = await db.collection("users").doc(uid).get();
        const userData = userDoc.data();
        if (userData?.name) {
          lateUserNames.push(userData.name);
        }
      }

      const penaltyDescription = data.selectedPenalty?.description || null;

      // System message text 구성
      let systemText = `약속 시간이 되었습니다! 약속 장소: ${address}, 시간: ${formattedTime}\n`;
      systemText += `✅ 도착한 사람들: ${arriveUserNames.length > 0 ? arriveUserNames.join(', ') : '없음'}\n`;

      if (penaltyDescription) {
        systemText += `🚫 벌칙 당첨자: ${lateUserNames.length > 0 ? lateUserNames.join(', ') : '없음'} (벌칙 내용: ${penaltyDescription})`;
      } else {
        systemText += `🚫 투표된 벌칙이 없습니다.`;
      }

      const message = {
        senderId: 'system',
        text: systemText,
        sentAt: new Date(),
        type: 'system',
        readBy: [],
      };

      await db
  .collection("promises")
  .doc(doc.id)
  .collection("messages")
  .add(message);

      console.log(`System message (full) sent for promise ${doc.id}`);
    } catch (error) {
      console.error(`Failed to send System message (full) for promise ${doc.id}`, error);
    }

    // FCM 알림 보내기
    for (const memberId of memberIds) {
      try {
        const userDoc = await db.collection("users").doc(memberId).get();
        const userData = userDoc.data();
        const tokens = userData?.fcmTokens || [];

        for (const token of tokens) {
          await sendFcm(token, `${data.name} 약속 시작!`, `지금 약속 시간이에요! 장소: ${address}`);
        }
      } catch (error) {
        console.error(`Failed to send FCM to user ${memberId}`, error);
      }
    }

    await doc.ref.update({
      notifyStartScheduled: true,
    });
  }));
});

// 공용 FCM 발송 함수
async function sendFcm(token, title, body) {
  try {
    await getMessaging().send({
      token,
      notification: {
        title,
        body,
      },
    });
    console.log(`FCM sent to token ${token}`);
  } catch (error) {
    console.error(`FCM failed to token ${token}`, error);
  }
}