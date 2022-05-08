
BOARD            = $(word 1, $(board_cfg))
MCU              = $(word 2, $(board_cfg))
ECLIPSE_HOME     = $(eclipse_home)
BOARD_FOLDER     = ./boards/$(BOARD)/src

# lookup the mcu specific template
IT_FILE_STM32F103 = stm32f1xx_it.c
IT_FILE_STM32F101 = stm32f1xx_it.c
IT_FILE_STM32F072 = stm32f0xx_it.c
IT_FILE           = $(IT_FILE_$(MCU))

STM32CUBEMX  = $(shell sh -c "find \"$(ECLIPSE_HOME)/plugins\" -name \"STM32CubeMX.jar\" -maxdepth 2 -mindepth 2")
PRJ_DIR      = $(shell sh -c "pwd")
BOARD_FOLDER_ABS = $(PRJ_DIR)/$(BOARD_FOLDER)
JRE_PLUGIN   = $(shell sh -c "find \"$(ECLIPSE_HOME)/plugins\" -name \"com.st.stm32cube.ide.jre.*\" -maxdepth 1 -type d")
JAVA         = $(JRE_PLUGIN)/jre/bin/java

default : all ;

# the default make in the STM32CubeMX is from 2016, does not support grouped targets
# if they decide to update make use grouped targets, that solves the issue of copying a template then running the cubemx generator on it:
#$(BOARD_FOLDER)/Core/Src/main.c $(BOARD_FOLDER)/Core/Inc/main.h $(BOARD_FOLDER)/Core/Src/$(IT_FILE) &: ../mcu/templates/main.c ../mcu/templates/main.h ../mcu/templates/$(IT_FILE) $(BOARD_FOLDER)/mcu_config.ioc
# also change the "all" target

# use a dummy "generated" file as a target
$(BOARD_FOLDER)/generated : ./mcu/templates/main.c ./mcu/templates/main.h ./mcu/templates/$(IT_FILE) $(BOARD_FOLDER)/mcu_config.ioc
	sh -c "cp ./mcu/templates/$(IT_FILE) $(BOARD_FOLDER)/Core/Src/$(IT_FILE)"
	sh -c "cp ./mcu/templates/main.h     $(BOARD_FOLDER)/Core/Inc/main.h"
	sh -c "cp ./mcu/templates/main.c     $(BOARD_FOLDER)/Core/Src/main.c"
	sh -c "cd \"$(BOARD_FOLDER_ABS)\"; \"$(JAVA)\" -jar \"$(STM32CUBEMX)\" -q \"$(PRJ_DIR)/mcu/cubemx_gen_script\""
	sh -c "touch $(BOARD_FOLDER)/generated"

all : $(BOARD_FOLDER)/generated

clean :
	sh -c "rm $(BOARD_FOLDER)/generated"
	sh -c "rm -r $(BOARD_FOLDER)/EWARM"
	sh -c "cd $(BOARD_FOLDER)/Core/Inc; find . -not -name 'GENERATED_FILES_DO_NOT_MODIFY' -delete"
	sh -c "cd $(BOARD_FOLDER)/Core/Src; find . -not -name 'GENERATED_FILES_DO_NOT_MODIFY' -delete"
	sh -c "cd $(BOARD_FOLDER)/Drivers; find . -not -name 'GENERATED_FILES_DO_NOT_MODIFY' -delete"
