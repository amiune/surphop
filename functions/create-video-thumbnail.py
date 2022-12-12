import os
from google.cloud import storage
from subprocess import check_output
from videoprops import get_video_properties

client = storage.Client()


def create_video_thumbnail(data, context):

  if data['contentType'].startswith('video/'):
       
     bucket = client.get_bucket(data['bucket'])
     name = data['name']
     os.makedirs('/tmp/'+os.path.dirname(name), exist_ok=True) 
     file_name = '/tmp/'+ name
     thumbnail_file_name = '/tmp/' + name.split('.')[0] + '.jpg'

     try:
          os.remove(file_name)
     except OSError:
          pass
     try:
          os.remove(thumbnail_file_name)
     except OSError:
          pass

     blob = bucket.get_blob(name)
     blob.download_to_filename(file_name)
     props = get_video_properties(file_name)

     if os.path.exists(file_name):       
          check_output('ffmpeg  -itsoffset -4  -i '+file_name+' -vcodec mjpeg -vframes 1 -an -f rawvideo -s '+str(props['width'])+'x'+str(props['height'])+' '+thumbnail_file_name, shell=True)
          thumbnail_blob = bucket.blob(name.split('.')[0] + '.jpg')
          thumbnail_blob.upload_from_filename(thumbnail_file_name)
          print("thumbnail created")

     try:
          os.remove(file_name)
     except OSError:
          pass
     try:
          os.remove(thumbnail_file_name)
     except OSError:
          pass