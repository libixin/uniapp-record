import store from '@/store'
import toast from "@/common/toast.js";
import i18n from '@/locale/i18n.js'
export default class WebsocketTask{
  constructor(url,time){
     this.url = url
     this.data = null
     this.isOpenSocket = false
     // 心跳检测
     this.timeout = time
     this.heartbeat = null
 
     try{
       return this.connectSocketInit()
     }catch(e){
       this.isOpenSocket = false
       this.reconnect();
     } 
  }

  connectSocketInit(){
    this.socketTask = uni.connectSocket({
      url: this.url,
	  success: () => {
			console.log("正准备建立websocket中...");
			// 返回实例
			// return this.socketTask
		},
    })
    this.socketTask.onOpen((res)=>{
      clearInterval(this.heartbeat);
      this.isOpenSocket = true
      // this.start();
      this.socketTask.onMessage((res)=>{
		  try{
		  	let notice = JSON.parse(res.data)
			if(notice.status !=2){
				store.commit('deviceNotice',notice)
			}else{
				//正在设备内操作被恢复出厂，回到index页面
				if(store.getters.device_sn == notice.devid){
					uni.switchTab({
						url: '../index/index'
					});
				}
				toast.alert(`${i18n.t('device.title')} ${notice.devid},${notice.time} ${i18n.t('setting.resetFactory')}，${i18n.t('toast.unbinded')}`,i18n.t('tip.factory.reset'))
			}
		  }catch(e){
		  	console.log(e);
		  }
		  console.log(JSON.parse(res.data),'上下线通知');
         //接收消息
      })
    })

    this.socketTask.onClose(()=>{
		console.log('websocket断开');
      this.isOpenSocket = false;
	  if(!!uni.getStorageSync('token_tkzl')){
		  this.reconnect();
	  }
    })
  }

  //发送消息
  send(data){
    this.socketTask.send({
       data,
    })
  }
  //开启心跳检测
  start(){
    this.heartbeat = setInterval(()=>{
       this.data = {value:'test'}
       this.send(JSON.stringify(this.data));
    }, this.timeout)
  }
  // 重新连接
  reconnect(){
   clearInterval(this.heartbeat)
   if(!this.isOpenSocket){
     setTimeout(()=>{
        this.connectSocketInit();
     }, 5000)
   }
  }
}