from distutils.core import setup
import py2exe

setup(console=[{'script':'logcat.py','icon_resources':[(1,'MyIcon.ico')]}],
      options = {'py2exe': {'bundle_files': 1, "dll_excludes":["MSVCP90.dll"]}}
      ,data_files=["PyDLLTest.dll"]
) 


