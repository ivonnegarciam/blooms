# blooms
_Phytoplankton Blooms in a Loop Current Eddy_

This repo includes some notes and instructions on how to set up, run and troubleshoot **WRF, NEMO** and **OASIS** on **chaman** (CICESE). 
Hope this helps to another lost soul!

## Uncoupled models
### WRF
1. [WRF Install & compile](https://github.com/ivonnegarciam/blooms/blob/main/models/uncoupled/install_configure_compile_WRF_4.1.3.md)
2. [WPS Install & compile](https://github.com/ivonnegarciam/blooms/blob/main/models/uncoupled/install_configure_compile_WPS_4.1.md)
3. [Pre-processing](https://github.com/ivonnegarciam/blooms/blob/main/models/uncoupled/pre-processing.md)
4. [Run](https://github.com/ivonnegarciam/blooms/blob/main/models/uncoupled/run.md)

### NEMO
1. [NEMO configure & compile](https://github.com/ivonnegarciam/blooms/edit/main/models/uncoupled/NEMO/install_configure_compile_NEMO_4.0.md)
2. [Run](https://github.com/ivonnegarciam/blooms/blob/main/models/uncoupled/NEMO/run_nemo.md)
3. [Create new experiment](https://github.com/ivonnegarciam/blooms/blob/main/models/uncoupled/NEMO/create_new_experiment.md)

### OASIS
1. [OASIS Install & compile](https://github.com/ivonnegarciam/blooms/blob/main/models/uncoupled/OASIS/install_compile_OASIS3-MCT_4.0.md)

### XIOS without OASIS
1. [XIOS compile without OASIS](https://github.com/ivonnegarciam/blooms/blob/main/models/coupled/XIOS_withoutOASIS/install_compile_XIOS2.5_withoutOASIS.md)

## Coupled models (NOW: NEMO-OASIS-WRF)
### XIOS with OASIS
1. [XIOS compile with OASIS](https://github.com/ivonnegarciam/blooms/tree/main/models/coupled/XIOS_withOASIS/install_compile_XIOS2.5_withoutOASIS.md)

### NEMO with OASIS & XIOS
Coming soon

### WRF with OASIS & XIOS
1. [WRF Install & compile](https://github.com/ivonnegarciam/blooms/blob/main/models/coupled/WRF_withOASIS_withXIOS/install_configure_compile_WRF_4.1.3_withOASIS_withXIOS.md)
2. [WPS Install & compile](https://github.com/ivonnegarciam/blooms/blob/main/models/coupled/WPS_withOASIS_withXIOS/install_configure_compile_WPS_4.1_withOASIS_withXIOS.md)
3. [Pre-processing](https://github.com/ivonnegarciam/blooms/blob/main/models/coupled/WPS_withOASIS_withXIOS/pre-processing_withOASIS_with_XIOS.md)
4. [Run](https://github.com/ivonnegarciam/blooms/blob/main/models/coupled/WRF_withOASIS_withXIOS/run_WPS_WRF_withOASIS_with_XIOS.md)

### NOW (NEMO-OASIS-WRF)
Coming soon

## Acknowledgements
The current compilation of notes and files includes inputs, comments and solutions proposed by several coleagues from CICESE and IRD-LEGOS. In particular, I would like to thank Julien Jouanno, Julio Sheinbaum, Favio Medrano, Fernando Andrade, Alejandro Dominguez Pérez and Marco Larrañaga for their technical support and guidance.

