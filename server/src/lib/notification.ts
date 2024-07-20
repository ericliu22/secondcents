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

	var tokens;
	if(typeof to === 'string') {
		console.log("STRING DETECTED")
		tokens = [to];
	} else {
		console.log("NOT STRING")
		tokens = to;
	}
	const message = {
		notification: notification,
		token: to,
		data: data
	};

	console.log(message.token);
	console.log(message.notification);
	console.log(message.data);

	getMessaging().send(message)
	.then((response) => {
		// Response is a message ID string.
		console.log('Successfully sent message:', response);
	})
	.catch((error) => {
		console.log('Error sending message:', error);
	});
}

function sendNotificationTopic(httpBody: any) {
	const { topic, notification, data } = httpBody

	const message = {
		notification: notification,
		topic: topic,
		data: data
	};

	getMessaging().send(message)
	.then((response) => {
		// Response is a message ID string.
		console.log('Successfully sent message:', response);
	})
	.catch((error) => {
		console.log('Error sending message:', error);
	});
}

export {
	sendNotification,
	sendNotificationTopic
}
