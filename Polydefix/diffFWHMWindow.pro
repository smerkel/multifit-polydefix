; *******************************************************************
; Polydefix stress, strain, and texture analysis for experiment in 
; angle dispersive geometry
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
; This window is copied/adapted from diffIntensitywindow
; It is used when plotting peak widths against diffraction azimut 
; for selected diffraction number(s) and peak(s)
; Added 05/06/2013 N. Hilairet 
; **************************************************************************

pro plotFWHMVsChi, base, globalbase, sets, peaks, dynamic, savemovie
common experimentwindow, set, experiment
common default, defaultdir
usePeak = WHERE(peaks, nUsePeak)
nSets = N_ELEMENTS(sets)
if ((sets[0] eq -1) or (nUsePeak eq 0)) then begin
  result = DIALOG_MESSAGE( "Error: no image or no diffraction line selected!", /CENTER , DIALOG_PARENT=base, /ERROR) 
  return
endif
; fetching data to plot
legend=strarr(nSets,nUsePeak)
data = OBJARR(nSets)
peakIndex = intarr(nUsePeak)
for i=0, nUsePeak-1 do peakIndex[i] = experiment->usedpeakindex(usePeak[i])
progressBar = Obj_New("SHOWPROGRESS", message='Processing, please wait...')
progressBar->Start
for i=0, nSets-1 do begin
	data[i] = experiment->getExperimentalData(sets[i])
	;for j=0, nUsePeak-1 do begin
	;	legend[i,j] = experiment->getFileName(sets[i]) + ' ' + experiment->getPeakName(peakIndex[j])
	;endfor
	legend[i] = experiment->getFileName(sets[i])
	percent = 100.*i/nSets
	progressBar->Update, percent
endfor
progressBar->Destroy
Obj_Destroy, progressBar
; getting a	name for movie file
if (dynamic and savemovie) then begin
	if (N_ELEMENTS(defaultdir) eq 0) then defaultdir = experiment->getDirectory()
	filters = [['*.mpg;*.mpeg'], ['MPG']]
	filename = DIALOG_PICKFILE(dialog_parent = base, filter=filters, /write , TITLE='Save movie as...', path=defaultdir, get_path = newdefaultdir);
	if (filename ne '') then defaultdir = newdefaultdir else savemovie=0
endif
; calling the plot window
plotPeakWidths, base, data, nSets, nUsePeak, peakIndex, usePeak, legend, experiment->getWavelength(), dynamic, savemovie, filename
end


; *********************************************************************** Interface ****************

pro diffFWHMWindow_event, ev
; Get the 'stash' structure.
WIDGET_CONTROL, ev.TOP, GET_UVALUE=stash
WIDGET_CONTROL, ev.ID, GET_UVALUE=uval
sets = WIDGET_INFO(stash.listSets, /LIST_SELECT)
WIDGET_CONTROL, stash.plotwhatPeak, GET_VALUE=peaks
if (WIDGET_INFO(stash.savemovie, /BUTTON_SET) eq 1) then savemovie = 1 else savemovie = 0
CASE ev.id OF
	stash.input:
	else: begin
		CASE uval OF
		'PLOT': plotFWHMVsChi, stash.input, stash.base, sets, peaks, 0, savemovie
		'DYNAMICPLOT': plotFWHMVsChi, stash.input, stash.base, sets, peaks, 1, savemovie
		'DONE': WIDGET_CONTROL, stash.input, /DESTROY
		else:
		ENDCASE
	end;case
	else:
endcase
end

pro diffFWHMWindow, base
common experimentwindow, set, experiment
common fonts, titlefont, boldfont, mainfont
; base GUI
input = WIDGET_BASE(Title='Diffraction peak widths at half maximum', /COLUMN, GROUP_LEADER=base)
inputLa = WIDGET_LABEL(input, VALUE='Diffraction peak widths at half maximum', /ALIGN_CENTER, FONT=titlefont)
fit = WIDGET_BASE(input, /ROW, FRAME=0)
; listing datasets
flist = WIDGET_BASE(fit,/COLUMN, /ALIGN_CENTER, FRAME=1,XSIZE=200, YSIZE=400)
filelist = experiment->getFileList()
listLa = WIDGET_LABEL(flist, VALUE='Datasets', /ALIGN_CENTER)
listSets = Widget_List(flist, VALUE=filelist, UVALUE='NOTHING', /MULTIPLE, SCR_XSIZE=190, SCR_YSIZE=360)
; Options
right = WIDGET_BASE(fit,/COLUMN, /ALIGN_CENTER, FRAME=1, YSIZE=400, XSIZE=200)
label =  WIDGET_LABEL(right, VALUE='Options', /ALIGN_CENTER)
buttons = WIDGET_BASE(right,/COLUMN, /ALIGN_LEFT, /NonExclusive)
savemovie = WIDGET_BUTTON(buttons, VALUE='Save dynamic plot in mpeg', UVALUE='NOTHING')
; peak list
values = experiment->getPeakList(/used)
plotwhatPeak = CW_BGROUP(right, values, /COLUMN, /NONEXCLUSIVE, LABEL_TOP='hkl', UVALUE='NOTHING', /SCROLL, Y_SCROLL_SIZE=270)
; buttons2
buttons2 = WIDGET_BASE(input,/ROW, /ALIGN_CENTER, /GRID_LAYOUT)
plot1 = WIDGET_BUTTON(buttons2, VALUE='Plot', UVALUE='PLOT')
plot2 = WIDGET_BUTTON(buttons2, VALUE='Dynamic Plot', UVALUE='DYNAMICPLOT')
close = WIDGET_BUTTON(buttons2, VALUE='Close window', UVALUE='DONE')
stash = {base: base, input: input, plotwhatPeak:plotwhatPeak, listSets:listSets, savemovie: savemovie}
WIDGET_CONTROL, input, SET_UVALUE=stash
WIDGET_CONTROL, input, /REALIZE
XMANAGER, 'diffFWHMWindow', input
end