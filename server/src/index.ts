import { Elysia } from 'elysia';
import { getNotification } from "./lib/notification.ts";

const app = new Elysia()



app.post('/api/notification', ({ body }) => {
	getNotification(body)
	return "Sent notification";
})

app.get('/api', ({ redirect }) => {
	return redirect('https://www.youtube.com/watch?v=dQw4w9WgXcQ&ab_channel=RickAstley')
})

app.get('/', () => {
	return "Gay";
})

app.listen(3000, () => {
	console.log(`Server is running at on port ${app.server?.port}...`)
});

