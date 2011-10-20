; *******************************************************************
; PolydefixED stress, strain, and texture analysis for experiment in 
; energy dispersive geometry
; Copyright (C) 2000-2011 S. Merkel, Universite Lille 1
; http://merkel.zoneo.net/Multifit/
; 
; This program is free software; you can redistribute it and/or
; modify it under the terms of the GNU General Public License
; as published by the Free Software Foundation; either version 2
; of the License, or (at your option) any later version.
; 
; This program is distributed in the hope that it will be useful,
; but WITHOUT ANY WARRANTY; without even the implied warranty of
; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
; GNU General Public License for more details.
;
; You should have received a copy of the GNU General Public License
; along with this program; if not, write to the Free Software
; Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.
;
; *******************************************************************

; ***************************************************************************
; plot d0 function
; plots d0(hkl) as a function of image number
; Add the /STRAIN parameter to plot vs. strain, will plot vs. step otherwise
; **************************************************************************

pro plotDSpacings, log, base, selected, STRAIN = st
common experimentwindow, set, experiment
common default, defaultdir
n = experiment->getnumberDatasets()
d = fltarr(2,n)
x = intarr(n)
d[*,*] = !VALUES.F_NAN
peakname = experiment->getPeakName(selected, /used)
h = experiment ->getH(selected, /used)
k = experiment ->getK(selected, /used)
l = experiment ->getL(selected, /used)
progressBar = Obj_New("SHOWPROGRESS", message='Calculating dspacings for '+peakname+', please wait...')
progressBar->Start
;print, 'Plotting ', h, k, l, selected, experiment->usedpeakindex(selected)
for i=0,n-1 do begin
	x[i] = i
	d1 = experiment->latticeStrainD0( i, selected, /used)
	cell = experiment->refineUnitCell(i)
	d2 = cell->getDHKL(h,k,l)
	;print, d1, d2
	OBJ_DESTROY, cell
	if ((abs(d1) eq !VALUES.F_INFINITY) or (fix(d1*1000) eq 0)) then d[0,i]=!VALUES.F_NAN else d[0,i]=d1
	if ((abs(d2) eq !VALUES.F_INFINITY) or (fix(d2*1000) eq 0)) then d[1,i]=!VALUES.F_NAN else d[1,i]=d2
	percent = 100.*i/n
	progressBar->Update, percent
endfor
xlabel = 'Step number'
ylabel = 'd0('+peakname+')'
title = 'd0('+peakname+') vs. step number'
if KEYWORD_SET(st) then begin
  x = experiment->getStrains()
  xlabel = 'Strain'
  title = 'd0('+peakname+') vs. strain'
endif
progressBar->Destroy
Obj_Destroy, progressBar
plotinteractive1D, base, x, d, title=title, xlabel=xlabel, ylabel=ylabel, legend=['Exp.', 'Recalc.']
end


; ***************************************************************************
; plot unit cell function
; plots one of the unit cell parameters as a function of image number
; Add the /STRAIN parameter to plot vs. strain, will plot vs. step otherwise
; **************************************************************************

pro plotUnitCell, log, base, selected, STRAIN = st
common experimentwindow, set, experiment
common default, defaultdir
n = experiment->getnumberDatasets()
d = fltarr(n)
x = intarr(n)
d[*] = !VALUES.F_NAN

parname = experiment->getCellParName(selected)
progressBar = Obj_New("SHOWPROGRESS", message='Calculating '+parname+', please wait...')
progressBar->Start
for i=0,n-1 do begin
	a = experiment->refineCellPar( i, selected)
	x[i] = i
	if ((abs(a) eq !VALUES.F_INFINITY) or (fix(a*1000) eq 0)) then d[i]=!VALUES.F_NAN else d[i]=a
	percent = 100.*i/n
	progressBar->Update, percent
endfor
xlabel = 'Step number'
ylabel = parname
title = parname +' vs. step number'
if KEYWORD_SET(st) then begin
  x = experiment->getStrains()
  xlabel = 'Strain'
  title = parname +' vs. strain'
endif
progressBar->Destroy
Obj_Destroy, progressBar
plotinteractive1D, base, x, d, title=title, xlabel=xlabel, ylabel=ylabel
end


; ***************************************************************************
; startRefineUnitCell
; verbose refinement of unit cell parameters
; for each diffraction pattern:
;   -> fits d0(hkl) for all peaks
;   -> fits a unit cell
;   -> recalculate the d0(hkl) from the fitted unit cells
;   -> prints the results in the log window
; **************************************************************************

pro startRefineUnitCell, log
common experimentwindow, set, experiment
n = experiment->getnumberDatasets()
logit, log, "Starting unit cell refinements"
for i=0,n-1 do begin
	logit, log, experiment->getDatasetName(i)
	cell = experiment->refineUnitCell(i)
	logit, log, cell->summaryLong()
	OBJ_DESTROY, cell
endfor
logit, log, "Finished..."
end

pro exportRefineUnitCellCSV, log
common experimentwindow, set, experiment
common default, defaultdir
result=dialog_pickfile(title='Save results as', path=defaultdir, DIALOG_PARENT=base, DEFAULT_EXTENSION='.csv', FILTER=['*.csv'], /WRITE, get_path = newdefaultdir)
if (result ne '') then begin
	defaultdir = newdefaultdir
	if (FILE_TEST(result) eq 1) then begin
		tmp = DIALOG_MESSAGE("File exists. Overwrite?", /QUESTION)
		if (tmp eq 'No') then return
	endif
	progressBar = Obj_New("SHOWPROGRESS", message='Calculating, please wait...')
	progressBar->Start
	openw, lun, result, /get_lun
	text = experiment->summaryUnitCellCSVAll(progressBar)
	printascii, lun, text
	free_lun, lun
	progressBar->Destroy
	Obj_Destroy, progressBar
endif
end

pro fitUnitCellWindow_event, ev
; Get the 'stash' structure.
WIDGET_CONTROL, ev.TOP, GET_UVALUE=stash
WIDGET_CONTROL, ev.ID, GET_UVALUE=uval
CASE ev.id OF
	stash.input:
	else: begin
		CASE uval OF
		'REFINE': startRefineUnitCell, stash.log
		'ASCII': exportRefineUnitCellCSV, stash.log
		'PLOTD0-STEP': BEGIN
			WIDGET_CONTROL, stash.plotwhatD0, GET_VALUE=selected
			plotDSpacings, stash.log, stash.base, selected
		END
    'PLOTD0-STRAIN': BEGIN
      WIDGET_CONTROL, stash.plotwhatD0, GET_VALUE=selected
      plotDSpacings, stash.log, stash.base, selected, /STRAIN
    END
		'PLOTUC-STEP': BEGIN
			WIDGET_CONTROL, stash.plotwhatUC, GET_VALUE=selected
			plotUnitCell, stash.log, stash.base, selected
		END
    'PLOTUC-STRAIN': BEGIN
      WIDGET_CONTROL, stash.plotwhatUC, GET_VALUE=selected
      plotUnitCell, stash.log, stash.base, selected, /STRAIN
    END
		'DONE': WIDGET_CONTROL, stash.input, /DESTROY
		else:
		ENDCASE
	endcase
endcase
end


pro fitUnitCellWindow, base
common experimentwindow, set, experiment
common fonts, titlefont, boldfont, mainfont
; check if experiment material properties are set
if (set eq 0) then begin
	result = DIALOG_MESSAGE( "Error: you have to input some data first!", /CENTER , DIALOG_PARENT=base, /ERROR) 
	return
endif
if (experiment->materialset() eq 0) then begin
	result = DIALOG_MESSAGE( "Error: you have to set some material properties first!", /CENTER , DIALOG_PARENT=base, /ERROR) 
	return
endif
; base GUI
input = WIDGET_BASE(Title='Unit cell refinements', /COLUMN, GROUP_LEADER=base)
inputLa = WIDGET_LABEL(input, VALUE='Unit cell refinements', /ALIGN_CENTER, FONT=titlefont)
fit = WIDGET_BASE(input, /ROW, FRAME=1)
; buttons1
buttons1 = WIDGET_BASE(fit,/COLUMN, /ALIGN_CENTER)
refine = WIDGET_BUTTON(buttons1, VALUE='Show details', UVALUE='REFINE')
export = WIDGET_BUTTON(buttons1, VALUE='Export to ASCII', UVALUE='ASCII')
plotD = WIDGET_BASE(buttons1,/COLUMN, /ALIGN_CENTER, /FRAME, XSIZE = 100)
values = experiment->getPeakList(/used)
plotwhatD0 = CW_BGROUP(plotD, values, /COLUMN, /EXCLUSIVE, LABEL_TOP='d0(hkl)', UVALUE='NOTHING', SET_VALUE=0)
plotit = WIDGET_BUTTON(plotD, VALUE='Plot vs. step', UVALUE='PLOTD0-STEP')
plotit = WIDGET_BUTTON(plotD, VALUE='Plot vs. strain', UVALUE='PLOTD0-STRAIN')
plotUC = WIDGET_BASE(buttons1,/COLUMN, /ALIGN_CENTER, /FRAME, XSIZE = 100)
values = experiment->getCellParList()
plotwhatUC = CW_BGROUP(plotUC, values, /COLUMN, /EXCLUSIVE, LABEL_TOP='Unit cell', UVALUE='NOTHING', SET_VALUE=0)
plotit = WIDGET_BUTTON(plotUC, VALUE='Plot vs. step', UVALUE='PLOTUC-STEP')
plotit = WIDGET_BUTTON(plotUC, VALUE='Plot vs. strain', UVALUE='PLOTUC-STRAIN')
; log
log = WIDGET_TEXT(fit, XSIZE=75, YSIZE=30, /ALIGN_CENTER, /EDITABLE, /WRAP, /SCROLL)
; buttons2
buttons2 = WIDGET_BASE(input,/ROW, /ALIGN_CENTER, /GRID_LAYOUT)
close = WIDGET_BUTTON(buttons2, VALUE='Close window', UVALUE='DONE')
stash = {base: base, input: input, log: log, plotwhatD0:plotwhatD0, plotwhatUC:plotwhatUC}
WIDGET_CONTROL, input, SET_UVALUE=stash
WIDGET_CONTROL, input, /REALIZE
XMANAGER, 'fitUnitCellWindow', input
end