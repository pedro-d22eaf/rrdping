# Configuration file containing the ping targets
CONFIG_FILE = ping-target.cfg

# Script to create RRD files
CREATE_RRD_SCRIPT = ./create_rrd.sh

RRDDATADIR=data

bootstrap: create_rrds

all: generate_pngs

# Extract targets from the configuration file and create RRD files
create_rrds:
	@echo "Reading targets from $(CONFIG_FILE)..."
	@if [ ! -f $(CONFIG_FILE) ]; then \
		echo "Error: Configuration file '$(CONFIG_FILE)' not found."; \
		exit 1; \
	fi
	@while IFS= read -r target || [ -n "$$target" ]; do \
		echo "Creating RRD for target: $$target"; \
		$(CREATE_RRD_SCRIPT) $(RRDDATADIR)"/$$target.rrd"; \
	done < $(CONFIG_FILE)

# Generate PNG files from RRD files
generate_pngs:
	@echo "Generating PNG files using generate_pngs.sh..."
	@./generate_pngs.sh

# Clean up generated RRD files
clean:
	@echo "Cleaning up RRD files..."
	@rm -f $(RRDDATADIR)/*.rrd
	@echo "Cleanup complete."

