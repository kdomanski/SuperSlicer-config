SLIC3R_PROFILES_COMMIT = c1bad3c
VORON_PROFILE_URL = https://github.com/slic3r/slic3r-profiles/raw/$(SLIC3R_PROFILES_COMMIT)/Voron.ini
VORON_PROFILE_DIGEST = 760ee5285a85a6ce798dd0996a3fcfb0fbc0385383feab9027166ea29b2fee1a
VORON_ORIGINAL = Voron-original-$(SLIC3R_PROFILES_COMMIT).ini

START_GCODE := '; M190 S0\\n; M109 S0 ; uncomment to remove set&wait temp gcode added automatically after this start gcode\\nSTART_PRINT EXTRUDER_TEMP={first_layer_temperature[initial_extruder] + extruder_temperature_offset[initial_extruder]} BED_TEMP=[first_layer_bed_temperature] CHAMBER=[chamber_temperature] MATERIAL=[filament_type] SIZE={first_layer_print_min[0]}_{first_layer_print_min[1]}_{first_layer_print_max[0]}_{first_layer_print_max[1]}'
END_GCODE := 'END_PRINT    ;end script from macro'
LAYER_GCODE := ';AFTER_LAYER_CHANGE\\nSET_PRINT_STATS_INFO CURRENT_LAYER=[layer_num] TOTAL_LAYER=[total_layer_count]'


all: vendor/Voron.ini

clean:
	rm -f Voron-original-*.ini vendor/Voron.ini

.DELETE_ON_ERROR: $(VORON_ORIGINAL)
$(VORON_ORIGINAL):
	curl -L -o $@ $(VORON_PROFILE_URL)
	@echo "$(VORON_PROFILE_DIGEST)  $@" | sha256sum -c

.PHONY: vendor/Voron.ini
.DELETE_ON_ERROR: vendor/Voron.ini
vendor/Voron.ini: $(VORON_ORIGINAL)
	cp $< $@
	./append_opt_in_section.sh '[printer_model:Voron_Switchwire_afterburner]' 'variants' '; volcano 0.4'
	./set_opt_in_section.sh '[printer:*common*]' 'start_gcode' $(START_GCODE)
	./set_opt_in_section.sh '[printer:*common*]' 'end_gcode' $(END_GCODE)
	./set_opt_in_section.sh '[printer:*common*]' 'layer_gcode' $(LAYER_GCODE)
	./set_opt_in_section.sh '[printer:*common*]' 'use_firmware_retraction' 1
	./set_opt_in_section.sh '[printer:*common*]' 'skirts' 0
	./set_opt_in_section.sh '[printer:*common*]' 'default_acceleration' 0
	./set_opt_in_section.sh '[printer:*common*]' 'thumbnails_with_bed' 0
	cat kd_addition.ini >> $@
