import { Elysia } from 'elysia';
import { sendNotification, sendNotificationTopic } from "./lib/notification.ts";
import { config } from "dotenv";

//NECESSARY TO IMPORT ENV FILES
config();

const app = new Elysia()

const admin = require("firebase-admin");
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
