
function getNotification(httpBody: any) {
	const title = httpBody.title
	const body = httpBody.body
	const image = httpBody.image

	console.log(title);
	if (image) {
	}
}

export {
	getNotification
}
