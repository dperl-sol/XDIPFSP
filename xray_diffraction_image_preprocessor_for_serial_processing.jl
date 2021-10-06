#XDIPFSP

using HDF5


#HDF5 plugin path is reset to the application default
#In a new process / https://github.com/dials/dials/issues/1260
ENV["HDF5_PLUGIN_PATH"] = "/home/proxima2/HDF5_PLUGINS/lib/plugins"

if isempty(ARGS)
    MASTER_FILE = "helix1_12keV_2_master.h5"
else
    MASTER_FILE = ARGS[1]
end

print(MASTER_FILE)