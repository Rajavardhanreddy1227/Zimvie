//import initDataMethod from "@salesforce/apex/b2B_CustomAddressComponentController.initData";

export default class b2B_CustomAddressComponentHelper {

    /*fetchData(state) {
        let jsonData = Object.assign({}, state)
        jsonData.numberOfRecords = state.numberOfRecords + 1
        jsonData = JSON.stringify(jsonData)
        return initDataMethod({ jsonData })
            .then(response => {
                const data = JSON.parse(response)
                return this.processData(data, state)
            })
            .catch(error => {
                console.log(error);
            });
    }

    processData(data, state){
        const records = data.records;
       // this.generateLinks(records)
        if (records.length > state.numberOfRecords) {
            records.pop()
            data.title = `${data.sobjectLabelPlural} (${state.numberOfRecords}+)`
        } else {
            data.title = `${data.sobjectLabelPlural} (${Math.min(state.numberOfRecords, records.length)})`
        }     
        return data
    }


    initColumnsWithActions(columns, customActions) {
         if (!customActions.length) {
            customActions = [
                { label: 'Edit', name: 'edit' },
                { label: 'Delete', name: 'delete' }
            ]
        }
        return [...columns, { type: 'action', typeAttributes: { rowActions: customActions } }]
       }

    flattenStructure(topObject, prefix, toBeFlattened) {
        for (const propertyName in toBeFlattened) {
            const propertyValue = toBeFlattened[propertyName];
            if (typeof propertyValue === 'object') {
                this.flattenStructure(topObject, prefix + propertyName + '_', propertyValue);
            } else {
                topObject[prefix + propertyName] = propertyValue;
            }
        }
    }*/
}