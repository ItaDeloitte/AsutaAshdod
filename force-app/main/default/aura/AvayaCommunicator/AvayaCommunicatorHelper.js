({
  init: function(cmp) {
    this.config(cmp);
  },
  controllers: {
    LC_AvayaCommunicator: 'LC_AvayaCommunicator'
  },
  CONSTANTS: {},
    
  callInfo: function(cmp, value) {
  	return this.attribute(cmp, 'callInfo', value);
  },
  markedupText: function(cmp, value) {
  	return this.attribute(cmp, 'markedupText', value);
  },
    
  config: function(component, event, helper) {    
      //const EXPECTED_ORIGIN = "https://sfdc1.asuta.co.il:8484";      
      //const EXPECTED_ORIGIN = "https://aslx2330v.asuta.co.il:8484";
      const EXPECTED_ORIGIN = "https://aslx2331v.asuta.co.il:8484";
      const EXPECTED_TARGET = window.location.origin;
      var delay = Math.random() * 5000 + 3000;
      
      let newMessageHandler = function(message) {
          let data = {}
          try {
            data = (message && message.data) ? JSON.parse(message.data) : undefined;
          } catch (e) {
            console.log(`json parse failed >>> `, e)
          }
          
          if ((data.class) && (data.class === "AvayaEvent")) {
              console.log("%cSalesforce Received Message", "color:green", data);
              
              if (message.origin !== EXPECTED_ORIGIN || data.origin !== EXPECTED_ORIGIN || data.origin !== message.origin) {
                  console.warn( "%cInvalid Origin","color:DarkRed", message.origin, data.origin);
                  return;
              } 
              
              if (message.currentTarget.location.origin !== EXPECTED_TARGET || data.target !== EXPECTED_TARGET) {
                  console.warn("%cInvalid Target", "color:DarkRed", message.currentTarget.location.origin, data.target);
                  return;
              }
 			
              if (data.payload.eventType != 'EstablishedEvent') {
                  console.log("%cInvalid eventType", "color:DarkRed", data.payload.eventType);
                  return;
              }

              let avayaEvent = component.getEvent("avayaEvent");          
              avayaEvent.setParams({"payload": data });
              
             
            setTimeout($A.getCallback(function(){
                avayaEvent.fire();
                console.log("%cNew Avaya Message Aura Component Event Fired", "color:Navy", data);
            }),delay);
            
          } else {
              console.log("%cNot Avaya Mesasage", "color:DarkRed", data);
              return;
          }
      };
      
      //window.removeEventListener('message', newMessageHandler);
      window.addEventListener('message', newMessageHandler, false);
	},
	/* {"class":"AvayaEvent","origin":"https://aslx2322v.asuta.co.il:8484","target":"https://assuta--uat.lightning.force.com",
	"payload":{"callId":"15095","eventSource":"call","uui":"100001 ;000003335;00001143181620759969;187_220930;360=N;a037E00000B29qFQAR;opt=1",
	"eventType":"IncomingEvent","dnis":"17733","ani":"0548559748","ucid":"00001143181620759969"}} */
	
    AvayaEvent: function(component, event, helper) {
        var that = this;
        let dataEvent = event.getParam("payload");   
		console.log("%cNew Avaya Message Aura Component Event Received by Handler", "color:#C00", dataEvent);        
        let json = JSON.stringify(dataEvent);
        //let jsonParse = JSON.parse(json);
        component.set("v.callInfo", json);
        let markedupText = component.get("v.markedupText") || "";
        markedupText += "<br>"+ json;
        component.set("v.markedupText", markedupText);	
        that.createCase(component);
    },
    
    createCase: function(cmp) {
    var that = this;
    let value = cmp.get("v.callInfo");
    let callInfo = {};
    try {
      callInfo = JSON.parse(value);
    } catch (e) {
      console.log(`ERROR JSON PARSE FAILED >>> `, e)
    }
    var ucid = callInfo.payload.ucid;

    var ucidMap = JSON.parse(localStorage.getItem('ucidMap')) || {};
    if (ucidMap[ucid]) {
        return;
    }
    ucidMap[ucid] = Date.now();
    localStorage.setItem('ucidMap', JSON.stringify(ucidMap));

    setTimeout(function(){
        var ucidMap = JSON.parse(localStorage.getItem('ucidMap')) || {};
        delete ucidMap[ucid];
        var rangeMs = Date.now()-1000*30;
        Object.keys(ucidMap).forEach(function(key){
            if(ucidMap[key]<rangeMs){
                delete ucidMap[key];
            }
        })
        localStorage.setItem('ucidMap', JSON.stringify(ucidMap));

    },15000);

    var params = {
      actionName: 'getRecordId',
      callDetails: value
    };
    return that
      .executeApex(cmp, {
          controllerName: that.controllers.LC_AvayaCommunicator,
          params: params
      })
      .then(that.BASE_RES_PIPES.statusPipe)
      .then(
      $A.getCallback(function(res) {        
                var recordId = res.responseObj.recordId;
                var userId = res.responseObj.userId;
                if(userId == $A.get("$SObjectType.CurrentUser.Id")){
                    var redirect = $A.get("e.force:navigateToSObject");
                    // Pass the record ID to the event
                    redirect.setParams({
                    "recordId": recordId
                    });
                    var TimeOut = new Date();
                    console.log('Get TimeOut before' + new Date());
                    console.log('Get TimeOut before' + TimeOut);
                    // Open the record
                    setTimeout($A.getCallback(function() {redirect.fire();}), 500);
                    console.log('Get TimeOut After' + new Date()); 
                }   
            })
    	)
      .catch(
      $A.getCallback(function(err) {
          console.log(err);
      })
    );
  }     
})