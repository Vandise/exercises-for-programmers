#Compiler and Linker
ASM          := nasm
LD           := ld

#The Target Binary Program
TARGET      := main
TESTTARGET  := test_suite

#The Directories, Source, Includes, Objects, Binary and Resources
SRCDIR      := src
TESTDIR     := test
INCDIR      := include
BUILDDIR    := obj
TARGETDIR   := bin
RESDIR      := res
SRCEXT      := asm
DEPEXT      := d
OBJEXT      := o

current_dir = $(shell pwd)

#---------------------------------------------------------------------------------
# EDIT ARCHITECTURE AND FLAGS HERE
#---------------------------------------------------------------------------------

#Flags, Libraries and Includes
ASM_FLAGS      := -f macho64 -g -F dwarf -l debug.l -I$(INCDIR)/
LINK_FLAGS     := -macosx_version_min 10.7.0 -lSystem

#---------------------------------------------------------------------------------
#DO NOT EDIT BELOW THIS LINE
#---------------------------------------------------------------------------------
SOURCES     := $(shell find $(SRCDIR) -type f -name *.$(SRCEXT))
OBJECTS     := $(patsubst $(SRCDIR)/%,$(BUILDDIR)/%,$(SOURCES:.$(SRCEXT)=.$(OBJEXT)))
MAINOBJS    := $(shell echo $(OBJECTS) | sed 's/[^ ]*test[^ ]* *//g')
TESTOBJS    := $(filter-out $(MAINOBJS), $(OBJECTS))

#Defauilt Make
all: directories $(TARGET)

#Remake
remake: cleaner all

#Copy Resources from Resources Directory to Target Directory
resources: directories
	@cp $(RESDIR)/* $(TARGETDIR)/

#Make the Directories
directories:
	mkdir -p $(TARGETDIR)
	mkdir -p $(BUILDDIR)

#Clean only Objecst
clean:
	$(RM) -rf $(BUILDDIR)
	$(RM) -rf $(TARGETDIR)

#Full Clean, Objects and Binaries
cleaner: clean
	$(RM) -rf $(TARGETDIR)

#Pull in dependency info for *existing* .o files
-include $(OBJECTS:.$(OBJEXT)=.$(DEPEXT))

#Link
$(TARGET): $(filter-out $(TESTOBJS),$(OBJECTS))
	$(LD) $(LINK_FLAGS) -o $(TARGETDIR)/$(TARGET) $^

$(TESTTARGET): $(filter-out $(BUILDDIR)/$(TARGET).$(OBJEXT),$(OBJECTS))
	$(LD) $(LINK_FLAGS) -o $(TARGETDIR)/$(TESTTARGET) $^

#Compile src
$(BUILDDIR)/%.$(OBJEXT): $(SRCDIR)/%.$(SRCEXT)
	mkdir -p $(dir $@)
	$(ASM) $(ASM_FLAGS) -o $@ $<
	$(ASM) $(ASM_FLAGS) $(SRCDIR)/$*.$(SRCEXT) > $(BUILDDIR)/$*.$(DEPEXT) 
	cp -f $(BUILDDIR)/$*.$(DEPEXT) $(BUILDDIR)/$*.$(DEPEXT).tmp
	sed -e 's|.*:|$(BUILDDIR)/$*.$(OBJEXT):|' < $(BUILDDIR)/$*.$(DEPEXT).tmp > $(BUILDDIR)/$*.$(DEPEXT)
	sed -e 's/.*://' -e 's/\\$$//' < $(BUILDDIR)/$*.$(DEPEXT).tmp | fmt -1 | sed -e 's/^ *//' -e 's/$$/:/' >> $(BUILDDIR)/$*.$(DEPEXT)
	rm -f $(BUILDDIR)/$*.$(DEPEXT).tmp
	rm -f $(SRCDIR)/*.o

#Non-File Targets
.PHONY: all remake clean cleaner