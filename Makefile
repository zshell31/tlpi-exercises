include Makefile.inc

TLPI_URL = "http://man7.org/tlpi/code/download/tlpi-151105-dist.tar.gz"

BUILD_DIRS = fileio proc

all: download buildlib build

cleanall: cleanlib clean

update: remove download

# Note: Order of defining targets is important
remove:
	@echo "Removing $(TLPI_DIR)"
	@rm -rf $(TLPI_DIR)

download:
ifeq ($(wildcard $(TLPI_DIR)),)
	@echo "Downloading tlpi files"
	/usr/bin/curl -OLsS $(TLPI_URL)

# Note: The following lines with '\' are shell commands
# @ in the beginning of the line suppresses echoing
	@FILE=`ls | grep "^tlpi.*dist\.tar\.gz"`; \
	echo "$$FILE was downloaded"; \
	tar xfz $$FILE; \
	rm $$FILE
endif

buildlib:
ifeq ($(wildcard $(TLPI_LIB)),)
	@echo "Making $(TLPI_LIB)"
	@cd $(TLPI_DIR)/lib && $(MAKE)
endif

build:
	@echo "Building"
# In old commits I used () instead of {} but it's wrong if we want to build files in more than one subdirectory
# In the case with () $$(dir) expanded to $(dir) that is an expression for command substitution
# so $(dir) = a list of subdirectories in the current directory and 
# cd $$(dir) ALWAYS takes the first word from the list, i.e. 'fileio'
#
# In the case with {} $${dir} expanded to ${dir} that is an expression for variable expansion
# so ${dir} is the next word from the list BUILD_DIRS
#
# Also use of ${BUILD_DIRS} or $(BUILD_DIRS) does not matter
	@for dir in $(BUILD_DIRS); do (cd $${dir}; $(MAKE)); done

cleanlib:
	@cd $(TLPI_DIR)/lib && $(MAKE) clean

clean:
	@for dir in $(BUILD_DIRS); do (cd $${dir}; $(MAKE) clean); done
