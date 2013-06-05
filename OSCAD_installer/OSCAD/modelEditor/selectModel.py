#!/usr/bin/python
# selectModel.py is a python script to select a component to create a model. It developed for OSCAD software. It is written by Yogesh Dilip Save (yogessave@gmail.com).  
# Copyright (C) 2012 Yogesh Dilip Save, FOSS Project, IIT Bombay.
# This program is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation; either version 2 of the License, or (at your option) any later version.
# This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.
# You should have received a copy of the GNU General Public License along with this program; if not, write to the Free Software Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA 02111-1307, USA.

from setPath import OSCAD_HOME
from Tkinter import *
from Tkinter import *
import template
import tkMessageBox
import os.path
import os
import Pmw
from string import maketrans

class ModelNameList():
  """Class for specifying parameter of the model"""
  def __init__(self,parent,filename):
    self.parent=parent
    self.modelName=""
    self.modelType=""
  # Collect model information from the circuit file
    try:
      self.OSCAD_HOME=OSCAD_HOME
    except NameError:
      try:
        self.OSCAD_HOME=os.environ["OSCAD_HOME"]
      except KeyError:
        tkMessageBox.showerror("Error OSCAD_HOME is not set","Please set OSCAD_HOME variable in .bashrc\n\nStep to set  OSCAD_HOME variable:\n  1) Open ~/.bashrc using text editor (vi ~/.bash).\n   2) Add the line \"Export OSCAD_HOME=<path_of_oscad>\" to it.\n  3) source ~/.bashrc")
        exit(0)

    HOME=self.OSCAD_HOME="/modelEditor/"
  # Open the circuit file 
    self.fileName=filename
  # Open parameter file
    if os.path.exists(self.fileName):
      try:
        f = open(self.fileName)
      except :
        tkMessageBox.showwarning("Bad input","Circuit netlist does not exit, please try again")
        return
    else:
        tkMessageBox.showwarning("Bad input","Circuit netlist does not exit, please try again")
        return

  # Read the data from file
    data=f.read()
  
  # Close the file
    f.close()
    netlist=data.splitlines()
  # Find the various model library required
    modelList=[]
    self.modelInfo={}
    for eachline in netlist:
      eachline=eachline.strip()
      if len(eachline)>1:
        eachline=eachline.lower()
        words=eachline.split()
        if eachline[0]=='d':
          modelName=words[3]
          modelType="D"
        elif eachline[0]=='q':
          modelName=words[4]
          transistors = ["NPN","PNP"]
          self.dialog1 = Pmw.SelectionDialog(parent,title = 'Select Transistor Type',buttons = ('OK', 'Cancel'),defaultbutton = 'OK',scrolledlist_labelpos = 'n', label_text = 'Please select one', scrolledlist_items=transistors)
          self.dialog1.pack(fill = 'both', expand=1, padx=5, pady=5)
          self.dialog1.activate()
          modelType = self.dialog1.getcurselection()
        elif eachline[0]=='m':
            modelName=words[4]
            transistors = ["nmos","pmos"]
            self.dialog1 = Pmw.SelectionDialog(parent,title = 'Select Transistor Type',buttons = ('OK', 'Cancel'),defaultbutton = 'OK',scrolledlist_labelpos = 'n', label_text = 'Please select one', scrolledlist_items=transistors)
            self.dialog1.pack(fill = 'both', expand=1, padx=5, pady=5)
            self.dialog1.activate()
            modelType = self.dialog1.getcurselection()
          
        else:
          continue
        if modelName in modelList:
          continue
        modelList.append(modelName)
        self.modelInfo[modelName]=modelType

  # Create the dialog.
    self.dialog = Pmw.SelectionDialog(parent,
      title = 'Model Selector',
      buttons = ('OK', 'Cancel'),
      defaultbutton = 'OK',
      scrolledlist_labelpos = 'n',
      label_text = 'Please select the model',
      scrolledlist_items=modelList,
      command = self.apply,
    )
    self.dialog.pack(fill = 'both', expand=1, padx=5, pady=5)
    self.dialog.activate()

  # Protocol when window is deleted.
    self.dialog.protocol("WM_DELETE_WINDOW",self.cancel)

  def apply(self,result):
    sels = self.dialog.getcurselection()
    if result=="OK":
      if len(sels) == 0:
        print 'You clicked on', result, '(no selection)'
        return
      else:
        self.modelName=sels[0]
        self.modelType=self.modelInfo[self.modelName]
        self.status=1
    else:
      self.status=0
    self.dialog.withdraw()
  # Put focus back to the parent window
    self.parent.focus_set()
  # Destroy child window
    self.dialog.deactivate()

# Action taken when cancel pressed
  def cancel(self, event=None, status=0):
  # Catch the status
    self.status=status
  # Put focus back to the parent window
    self.parent.focus_set()
  # Destroy child window
    self.destroy()

if __name__=='__main__':
  root=Tk()
  model= ModelNameList(root,"xxx")
  mainloop()

