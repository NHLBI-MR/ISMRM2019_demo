import numpy as np
from   gadgetron   import   Gadget
import ismrmrd
import ismrmrd.xsd



class PhaseDifference(Gadget):
   myBuffer = 0
   myParameters = 0
   dTE = 0.001 # == 1 ms
   nBinsHistogram = 100
   dataHeader = ''



   def process_config(self, conf):

      self.dataHeader = ismrmrd.xsd.CreateFromDocument(conf)
      
      print ("Scanner center frequency is {0} ".format(self.dataHeader.experimentalConditions.H1resonanceFrequency_Hz))
      print ("Experiment's  1st TE is {0}".format(self.dataHeader.sequenceParameters.TE[0]))
      print ("Experiment's  2nd TE is {0}".format(self.dataHeader.sequenceParameters.TE[1]))
 
      self.dTE = (self.dataHeader.sequenceParameters.TE[1] -
                  self.dataHeader.sequenceParameters.TE[0]) * 0.001  # scale ms -> s

      self.myBuffer = (np.zeros((self.dataHeader.acquisitionSystemInformation.receiverChannels,
                                 1, # self.dataHeader.encoding[0].encodedSpace.matrixSize.z
                                 self.dataHeader.encoding[0].encodedSpace.matrixSize.y,
                                 self.dataHeader.encoding[0].encodedSpace.matrixSize.x))).astype('complex64')



   def process(self, h, data):

      h.channels = 1

      if h.contrast == 0:
         # Store the data from the first contrast to compute field map with
         # 2nd contrast
         # myBuffer[:,h.slice,:,:] = data
         self.myBuffer = data
         # Send the RSOS image on
         h.image_series_index = (self.dataHeader.measurementInformation.initialSeriesNumber * 100)
         h.image_type = 1  # Magnitude
         sos = np.sqrt(np.sum(np.square(np.abs(data)),axis=3))

         # Autoscale the magnitude data, since the default AutoScale Gadget
         # does not properly handle multiple image types being sent in the
         # same reconstruction ...

         maxPrescaled           = sos.max()
         imageHistogram         = np.zeros (self.nBinsHistogram, dtype = np.uint16)
         imageScaledByNBins     = np.zeros (self.nBinsHistogram, dtype = np.uint16)
         imageScaledByNBins     = np.floor ((sos / maxPrescaled) * self.nBinsHistogram)
         imageScaledByNBins[imageScaledByNBins >= self.nBinsHistogram] = \
                                                         self.nBinsHistogram - 1
         imageHistogram, edges  = np.histogram(imageScaledByNBins, self.nBinsHistogram)

         cumulativeSum          = np.cumsum (imageHistogram)

         desiredIndex           = len (cumulativeSum[cumulativeSum < (0.99 *
                                          self.dataHeader.encoding[0].encodedSpace.matrixSize.y *
                                          self.dataHeader.encoding[0].encodedSpace.matrixSize.x)])

         maxScaledByBins        = desiredIndex * maxPrescaled / self.nBinsHistogram
         imageScalingFactor     = 16383 / maxScaledByBins

         sos *= imageScalingFactor

         self.put_next(h, sos.astype('complex64'))

      else:
         # Send the field map estimate to a different series
         h.image_series_index = (self.dataHeader.measurementInformation.initialSeriesNumber * 100) + 1
         h.image_type = 3  # Real values
         # fm = np.angle(np.sum(np.conj(self.myBuffer[:,h.slice,:,:])*(data),axis=0))
         fm = np.angle(np.sum(np.conj(self.myBuffer)*(data),axis=3))

         fm = fm / (self.dTE * 2.0 * np.pi)
         # We have converted from radians to Hz.  Now shift everything up by
         # 2^14, till we figure out how to create DICOMs with negative values.
         # 2^15 = 32768 == max range of signed short int, so we need to shift
         # by half == 2^14 == 16384
         fm[fm < -16384] = -16384
         fm[fm >  16383] =  16383
         # Now make it +ve for the unsigned short int range than dcmtk can use.
         fm += 16383
         self.put_next(h,fm.astype('complex64'))

      return 0

