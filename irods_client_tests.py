import os
import pytest

from irods.session import iRODSSession

def test_get_collection():
    with iRODSSession(host=os.environ['IRODS_HOST'], 
        port=os.environ['IRODS_PORT'], 
        user=os.environ['IRODS_USER'],  
        password=os.environ['IRODS_PASSWORD'], 
        zone=os.environ['IRODS_ZONE']) as session:

        zone=os.environ['IRODS_ZONE']
        user=os.environ['IRODS_USER']
        aCollection = "/" + zone + "/home/" + user
    
        coll = session.collections.get(aCollection)
        assert coll.path == aCollection, "Test failed! Got wrong collection path"
