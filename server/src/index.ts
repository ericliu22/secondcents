import { Elysia } from 'elysia';
import { getNotification } from "./lib/notification.ts";

const app = new Elysia()
	.post('/api/notification', ({ body }) => {
		getNotification(body)
		return "Sent notification";
	})
	.get('/api', ({ redirect }) => {
		return redirect('https://www.youtube.com/watch?v=dQw4w9WgXcQ&ab_channel=RickAstley')
	})
	.get('/', () => {
		return "Gay";
	})
	.listen(3000)

console.log(`Server is running at on port ${app.server?.port}...`)
