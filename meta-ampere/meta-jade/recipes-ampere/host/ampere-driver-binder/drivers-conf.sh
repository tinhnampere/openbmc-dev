DELAY_BEFORE_BIND=0

# Each driver include driver name and driver path
declare -a DRIVER_NAMEs=("1e78a0c0.i2c-bus:smpro@4f:hwmon"
                         "1e78a0c0.i2c-bus:smpro@4e:hwmon"
                         "1e78a0c0.i2c-bus:smpro@4f:errmon"
                         "1e78a0c0.i2c-bus:smpro@4e:errmon"
                         "1e78a0c0.i2c-bus:smpro@4f:misc"
                         "1e78a0c0.i2c-bus:smpro@4e:misc"
                        )
# Driver path should include / at the end
declare -a DRIVER_PATHs=("/sys/bus/platform/drivers/smpro-hwmon/"
                         "/sys/bus/platform/drivers/smpro-hwmon/"
                         "/sys/bus/platform/drivers/smpro-errmon/"
                         "/sys/bus/platform/drivers/smpro-errmon/"
                         "/sys/bus/platform/drivers/smpro-misc/"
                         "/sys/bus/platform/drivers/smpro-misc/"
                        )