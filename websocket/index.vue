<script>
	import WebsocketTask from '@/services/websocket.js'
	export default {
		mounted() {
			new WebsocketTask(`${service.websocketUrl}?userid=${this.id}&password=${this.password}`)
		}
	}
</script>