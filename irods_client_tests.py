import os
import pytest
import shutil
import ssl

from irods.exception import CollectionDoesNotExist
from irods.exception import DataObjectDoesNotExist
from irods.session import iRODSSession

def test_get_existing_collection():
    with iRODSSession(host=os.environ['IRODS_HOST'], 
        port=os.environ['IRODS_PORT'], 
        user=os.environ['IRODS_USER'],  
        password=os.environ['IRODS_PASSWORD'], 
        zone=os.environ['IRODS_ZONE']) as session:

        zone=os.environ['IRODS_ZONE']
        user=os.environ['IRODS_USER']
        aCollection = "/" + zone + "/home/" + user
    
        coll = session.collections.get(aCollection)
        assert coll.path == aCollection, "Error! Got wrong collection path"
        assert len(coll.subcollections) == 0, "Error! Collection should not have any subcollections!"
        assert len(coll.data_objects) == 0, "Error! Collection should not have any data objects!" 

def test_create_delete_new_collection():
    with iRODSSession(host=os.environ['IRODS_HOST'], 
        port=os.environ['IRODS_PORT'], 
        user=os.environ['IRODS_USER'],  
        password=os.environ['IRODS_PASSWORD'], 
        zone=os.environ['IRODS_ZONE']) as session:

        zone=os.environ['IRODS_ZONE']
        user=os.environ['IRODS_USER']
        newCollection = "/" + zone + "/home/" + user + "/testdir"
    
        coll = session.collections.create(newCollection)
        assert coll.path == newCollection, "Error! Got wrong collection path"
        assert len(coll.subcollections) == 0, "Error! Collection should not have any subcollections!"
        assert len(coll.data_objects) == 0, "Error! Collection should not have any data objects!" 

        coll.remove(recurse=True, force=True)

        with pytest.raises(CollectionDoesNotExist):
            coll = session.collections.get(newCollection)

def test_create_delete_new_data_object():
    with iRODSSession(host=os.environ['IRODS_HOST'], 
        port=os.environ['IRODS_PORT'], 
        user=os.environ['IRODS_USER'],  
        password=os.environ['IRODS_PASSWORD'], 
        zone=os.environ['IRODS_ZONE']) as session:

        zone=os.environ['IRODS_ZONE']
        user=os.environ['IRODS_USER']
        newCollection = "/" + zone + "/home/" + user + "/testdir"
        newDataObject = newCollection + "/testDataObject"
   
        # Create new collection 
        coll = session.collections.create(newCollection)
        assert coll.path == newCollection, "Error! Got wrong collection path"
        assert len(coll.subcollections) == 0, "Error! Collection should not have any subcollections!"
        assert len(coll.data_objects) == 0, "Error! Collection should not have any data objects!" 

        # Create data object
        obj = session.data_objects.create(newDataObject)
        assert obj.name == "testDataObject", "Error! Got wrong data object"

        
        # Delete data object
        obj.unlink(force=True)

        # Get data object
        with pytest.raises(DataObjectDoesNotExist):
            obj = session.data_objects.get(newDataObject)

        # Delete collection
        coll.remove(recurse=True, force=True)

        with pytest.raises(CollectionDoesNotExist):
            coll = session.collections.get(newCollection)

def test_populate_fetch_new_data_object():
    with iRODSSession(host=os.environ['IRODS_HOST'], 
        port=os.environ['IRODS_PORT'], 
        user=os.environ['IRODS_USER'],  
        password=os.environ['IRODS_PASSWORD'], 
        zone=os.environ['IRODS_ZONE']) as session:

        zone=os.environ['IRODS_ZONE']
        user=os.environ['IRODS_USER']
        newCollection = "/" + zone + "/home/" + user + "/testdir"
        fileName = "irods_beginner_training_2016.pdf"
        backupFileName = "irods_beginner_training_2016_backup.pdf"

        # Copy file from backup
        shutil.copyfile(fileName, backupFileName)
   
        # Create new collection 
        coll = session.collections.create(newCollection)
        assert coll.path == newCollection, "Error! Got wrong collection path"
        assert len(coll.subcollections) == 0, "Error! Collection should not have any subcollections!"
        #assert len(coll.data_objects) == 0, "Error! Collection should not have any data objects!" 

        # Create new data object
        session.data_objects.put(backupFileName, newCollection + "/")

        # Delete local file
        os.remove(backupFileName)         

        # Get the data object back
        obj = session.data_objects.get(newCollection + "/" + backupFileName)

        # Write the data object to the file system
        with obj.open("r") as f_in, open(backupFileName, "wb") as f_out:
            f_out.write(f_in.read())

        # Assert the size of file fetched from iRODS matches the local backup copy
        assert os.path.getsize(fileName) == os.path.getsize(backupFileName), "Error! Size of file fetched from iRODS does not match the size of the original file" 

        # Delete local file
        os.remove(backupFileName)         

        # Delete data object
        obj.unlink(force=True)

        # Get data object
        with pytest.raises(DataObjectDoesNotExist):
            obj = session.data_objects.get(newCollection + "/" + backupFileName)

        # Delete collection
        coll.remove(recurse=True, force=True)

        # Get collection
        with pytest.raises(CollectionDoesNotExist):
            coll = session.collections.get(newCollection)

'''
def test_get_collection_2():
    try:
        env_file = os.environ['IRODS_ENVIRONMENT_FILE']
    except KeyError:
        env_file = os.path.expanduser('~/.irods/irods_environment.json')

    ssl_context = ssl.create_default_context(purpose=ssl.Purpose.SERVER_AUTH, cafile=None, capath=None, cadata=None)
    ssl_settings = {'ssl_context': ssl_context}
    with iRODSSession(irods_env_file=env_file, **ssl_settings) as session:
        zone=os.environ['IRODS_ZONE']
        user=os.environ['IRODS_USER']
        aCollection = "/" + zone + "/home/" + user
   
        coll = session.collections.get(aCollection)
        assert coll.path == aCollection, "Test failed! Got wrong collection path"
'''
