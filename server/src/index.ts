import { Elysia } from 'elysia';
import { sendNotification, sendNotificationTopic } from "./lib/notification.ts";
import * as admin from "firebase-admin";

const app = new Elysia()


if (!process.env.SERVICE_ACCOUNT_FILEPATH) {
	throw new Error("Failed to start server: enviornment variable SERVICE_ACCOUNT_FILEPATH not set");
}

var serviceAccount = require(process.env.SERVICE_ACCOUNT_FILEPATH);

admin.initializeApp({
	credential: admin.credential.cert(serviceAccount)
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
