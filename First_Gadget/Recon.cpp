#include <gadgetron/Gadget.h>
#include <gadgetron/hoNDFFT.h>
#include <gadgetron/mri_core_utility.h>
#include <gadgetron/ChannelAlgorithms.h>
#include <gadgetron/log.h>
#include <gadgetron/mri_core_coil_map_estimation.h>
using namespace Gadgetron;
using namespace Gadgetron::Core;

class SimpleRecon : public TypedChannelGadget<Acquisition> {

    public:
        SimpleRecon(const Context& context, const GadgetProperties& params) : TypedChannelGadget<Acquisition>(params), header{context.header} {

        }

        void process(TypedInputChannel<Acquisition>& in, OutputChannel& out){

            auto recon_size = header.encoding[0].encodedSpace.matrixSize;
            auto data = hoNDArray<std::complex<float>>(recon_size.x,recon_size.y,recon_size.z,header.acquisitionSystemInformation->receiverChannels.get());

            ISMRMRD::AcquisitionHeader saved_header;

            auto stop_condition = [](auto& message){
              return !std::get<ISMRMRD::AcquisitionHeader>(message).isFlagSet(ISMRMRD::ISMRMRD_ACQ_LAST_IN_ENCODE_STEP1);
            };

            for ( auto [acq_header, acq_data, trajectories] : take_while(in,stop_condition)){
                saved_header = acq_header;
                data(slice,acq_header.idx.kspace_encode_step_1,0,slice) = acq_data;
            }

            hoNDFFT<float>::instance()->fft2c(data);

            auto coil_map = coil_map_Inati(data);
            data = coil_combine(data,coil_map,3);
            
            auto image_header = image_header_from_acquisition(saved_header,header,data);

            out.push(image_header,data);

        }
    private:
        const ISMRMRD::IsmrmrdHeader header;
};

GADGETRON_GADGET_EXPORT(SimpleRecon)