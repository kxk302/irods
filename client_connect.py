from irods.session import iRODSSession

with iRODSSession(host='localhost', port=1247, user='rods', password='rods', zone='tempZone') as session:
    coll = session.collections.get("/tempZone/home/rods")
    print('collection id: ', coll.id)
    print('collection path: ', coll.path)

    session.data_objects.put("client_connect.txt","/tempZone/home/rods/test")
    obj2 = session.data_objects.get("/tempZone/home/rods/test")
    print('obj2.id: ', obj2.id)
