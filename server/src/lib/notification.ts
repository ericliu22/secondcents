const FCM_API_URL = "https://fcm.googleapis.com/fcm/send";

function getNotification(httpBody: any) {
	const { to, notification } = httpBody.title

	const fcmMessage = JSON.stringify({
		to,
		notification,
	});
	const request = new XMLHttpRequest();
	request.open("POST", FCM_API_URL, true);
	request.setRequestHeader('Content-Type', 'application/json');
	request.setRequestHeader('Authorization', `key=${process.env.FCM_SERVER_KEY}`);
}

export {
	getNotification
}
