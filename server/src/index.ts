import { Elysia } from 'elysia';
import { sendNotification, sendNotificationTopic } from "./lib/notification.ts";
import { config } from "dotenv";
import admin from "firebase-admin";

//NECESSARY TO IMPORT ENV FILES
config();

const app = new Elysia()

admin.initializeApp({
	credential: admin.credential.applicationDefault()
});

app.post('/api/notification', ({ body }) => {
	sendNotification(body)
	return "Sent notification";
})

app.post('/api/notification-topic', ({ body }) => {
	sendNotificationTopic(body)
	return "Sent notification";
})

app.get('/api', ({ redirect }) => {
	return redirect('https://www.youtube.com/watch?v=dQw4w9WgXcQ&ab_channel=RickAstley')
})

app.get('/', () => {
	return "Home page";
})

app.listen(process.env.PORT ?? 8080, () => {
	console.log(`Server is running at on port ${app.server?.port}...`)
});

const testNotification = {
	title: "HELLO FROM SERVER",
	body: "An actual notification from the server"
};

const testBody = {
	to: "coc5utRXp00vkWGM7met4r:APA91bFyMUyzKCQu2c45Pm-hqWE_eppgoDIqiIIkIwLGVOy2rUORVmtwBNDpQaD8LX1T9YtSeNmBJlKIsp4iL5jwvrPF9XEKCKtu9U4PmF7dpdkr8C3kvlBtRkqzqG8wPOYb7CBhC1aa",
	notification: testNotification
}

sendNotification(testBody)
