import { getMessaging } from "firebase-admin/messaging";


/*DEPRECATED

const FCM_API_URL = "https://fcm.googleapis.com/fcm/send";

function newNotificationRequest() {
	const request = new XMLHttpRequest();
	request.open("POST", FCM_API_URL, true);
	request.setRequestHeader('Content-Type', 'application/json');
	request.setRequestHeader('Authorization', `key=${process.env.FCM_SERVER_KEY}`);
	return request;
}
*/

function sendNotification(httpBody: any) {
	const { to, notification, data } = httpBody

	let tokens;
	if(typeof to == 'string') {
		tokens = [to];
	} else {
		tokens = to;
	}
	const message = {
		notification: notification,
		token: to,
		data: data
	};

	getMessaging().send(message)
}

function sendNotificationTopic(httpBody: any) {
	const { topic, notification, data } = httpBody

	const message = {
		notification: notification,
		topic: topic,
		data: data
	};

	getMessaging().send(message)
}

export {
	sendNotification,
	sendNotificationTopic
}
