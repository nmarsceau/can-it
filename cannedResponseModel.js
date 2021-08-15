import { openDB } from 'https://unpkg.com/idb?module';

export class cannedResponseModel {
  async #openDatabase() {
    return openDB('canIt', 1, {
      upgrade(database, oldVersion, newVersion, transaction) {
        if (!database.objectStoreNames.contains('cannedResponses')) {
          database.createObjectStore('cannedResponses', {keyPath: 'name'});
        }
      }
    });
  }

  async getCannedResponseNames() {
    const database = await openDatabase();
    const names = await database.getAllKeys('cannedResponses');
    database.close();
    return names;
  }
  
  async getCannedResponse(name) {
    const database = await openDatabase();
    const cannedResponse = await database.get('cannedResponses', name);
    database.close();
    return cannedResponse;
  }
  
  async setCannedResponse(cannedResponse) {
    const database = await openDatabase();
    database.put('cannedResponses', cannedResponse);
    database.close();
  }
}
