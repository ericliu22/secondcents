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
	title: "I like james charles",
	body: "Gyatt"
};

/*
const testBody = {
	to: "eZx-VtX3Lkm-iyK4Ky99rL:APA91bEvnTqEI0asvDcqYKxQPIurbjvUFIdxKDCjgssBRjWq8W8LU8VOilnoJ_TWClLKrToJY4if-UMsnUEQwSzuoHmjYq1wb4Bodtl5Qk05y4uee8HzXhbI9ySbwl-UmJcV5mnJPORs",
	notification: testNotification
}
*/
