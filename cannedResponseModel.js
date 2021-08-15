import { openDB } from 'https://unpkg.com/idb?module';

export class cannedResponseModel {
  static async #openDatabase() {
    return openDB('canIt', 1, {
      upgrade(database, oldVersion, newVersion, transaction) {
        if (!database.objectStoreNames.contains('cannedResponses')) {
          database.createObjectStore('cannedResponses', {keyPath: 'name'});
        }
      }
    });
  }

  static async getCannedResponseNames() {
    const database = await cannedResponseModel.#openDatabase();
    const names = await database.getAllKeys('cannedResponses');
    database.close();
    return names;
  }
  
  static async getCannedResponse(name) {
    const database = await cannedResponseModel.#openDatabase();
    const cannedResponse = await database.get('cannedResponses', name);
    database.close();
    return cannedResponse;
  }
  
  static async setCannedResponse(cannedResponse) {
    const database = await cannedResponseModel.#openDatabase();
    database.put('cannedResponses', cannedResponse);
    database.close();
  }
}
