({
    doInit: function(cmp) {
        cmp.set('v.columns', [
            {label: 'Service Type', fieldName: 'serviceType', type: 'text'},
            {label: 'Expected DeliveryDate', fieldName: 'expectedDeliveryDate', type: 'date'},
            {label: 'Total Weight', fieldName: 'totalWeight', type: 'text'},
            {label: 'Total Surcharge', fieldName: 'totalSurcharge', type: 'text'},
            {label: 'Total Charge', fieldName: 'totalCharge', type: 'text'},
            {label: 'Apply Rate', type: "button", typeAttributes: {
                label: 'Apply this rate',
                title: 'Apply this rate',
                disabled: false,
                iconPosition: 'left'
            }}
        ]);
        
        let toastEvent = $A.get("e.force:showToast");
        let action = cmp.get("c.calcRates");
        cmp.set("v.spinner", true);
        action.setParams({ recId : cmp.get("v.recordId")});
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                cmp.set('v.data',response.getReturnValue());
                cmp.set('v.isModalOpen',true);
                cmp.set("v.spinner", false);
            }
            else if (state === "INCOMPLETE") {
                // do something
            }else if (state === "ERROR") {
                var errors = response.getError();
                if (errors) {
                    toastEvent.setParams({
                        title : 'Error Message',
                        message: errors[0] && errors[0].message,
                        duration:' 10000',
                        key: 'info_alt',
                        type: 'error',
                        mode: 'dismissible'
                    });
                } else {
                    toastEvent.setParams({
                        title : 'Error Message',
                        message: 'Unknown error',
                        duration:' 10000',
                        key: 'info_alt',
                        type: 'error',
                        mode: 'dismissible'
                    });                        
                }
                toastEvent.fire(); 
                cmp.set("v.spinner", false);
                $A.get("e.force:closeQuickAction").fire();
                $A.get('e.force:refreshView').fire();                
            }
        });
        $A.enqueueAction(action);
    },
    onUpdateQuote: function(cmp,event) {
        cmp.set("v.spinner", true);
        var action = cmp.get("c.updateQuote");
        var row = event.getParam('row');
        console.log(row);
        var data = [];
        data.push(row);
        action.setParams({recId : cmp.get("v.recordId"),
                          shippingRate : JSON.stringify(data)
                         });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                console.log(response.getReturnValue());
                cmp.set("v.spinner", false);
                $A.get("e.force:closeQuickAction").fire();
                $A.get('e.force:refreshView').fire();
            }
            else if (state === "INCOMPLETE") {
                // do something
            }else if (state === "ERROR") {
                var toastEvent = $A.get("e.force:showToast");
                var errors = response.getError();
                if (errors) {
                    toastEvent.setParams({
                        title : 'Error Message',
                        message: errors[0] && errors[0].message,
                        duration:' 10000',
                        key: 'info_alt',
                        type: 'error',
                        mode: 'dismissible'
                    });
                } else {
                    toastEvent.setParams({
                        title : 'Error Message',
                        message: 'Unknown error',
                        duration:' 10000',
                        key: 'info_alt',
                        type: 'error',
                        mode: 'dismissible'
                    });                        
                }
                toastEvent.fire(); 
                cmp.set("v.spinner", false);
            }
        });
        $A.enqueueAction(action);
    }
})