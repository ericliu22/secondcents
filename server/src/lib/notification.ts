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
	const { to, notification } = httpBody

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
		token: to
	};

	console.log(message.token);

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
	const { topic, notification } = httpBody

	const message = {
		notification: notification,
		topic: topic
	}

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
