#XDIPFSP

<<<<<<< Updated upstream
using HDF5
using YAML

=======
>>>>>>> Stashed changes
#HDF5 plugin path is reset to the application default
#In a new process / https://github.com/dials/dials/issues/1260
ENV["HDF5_PLUGIN_PATH"] = "/home/proxima2/HDF5_PLUGINS/lib/plugins"

<<<<<<< Updated upstream
if isempty(ARGS)
    MASTER_FILE = "helix1_12keV_2_master.h5"
else
    MASTER_FILE = ARGS[1]
end

datafile=h5open(MASTER_FILE,"r")
data_list = names(datafile["entry/data/"])
mask_data = YAML.load_file("mask.yml")
=======
using Logging
using HDF5
using YAML
using ArgParse
using ProgressBars

include("general_util.jl")
include("mask_util.jl")
include("geom_util.jl")

function parse_commandline()
    s = ArgParseSettings()

    @add_arg_table s begin
        #=
        "--opt1", ""
            help = "an option with an argument"
        =#
        "--mask", "-m"
        help = "specify a mask file (in YAML) to add to the bad pixels"
        arg_type = String
        "--geom-only", "-g"
            help = "only prepare a geometry file, don't process images"
            action = :store_true
        "master_file"
            help = "The hdf5 master file you want to process"
            required = true
        "output_folder"
            help = "The folder where you want to save output, e.g. \"output/\""
            required = true
    end

    return parse_args(s)
end

function main()
    #= Initialise
        - get command line arguments
        - use a test file or one supplied by command line
        - get some basic info about the dataset
    =#
    parsed_args = parse_commandline()
    output_folder = parsed_args["output_folder"]
    datafile = h5open(parsed_args["master_file"],"r")
    data_list = keys(datafile["entry/data"])
    last_dataset = (datafile["entry/data/" * data_list[end]])
    #highest_image = read_attribute(last_dataset, "image_nr_high")

    #= Geometry and mask
        -use geom_util.jl to write a crystFEL geometry file
    =#
    @info "writing geometry file to "*output_folder*"geom.geom"
    write_geometry_file(datafile,output_folder*"geom.geom")


    if !parsed_args["geom-only"]
        #= Mask
            -use mask_util.jl to process the pixel mask
        =#
        @info "preparing pixel mask"
        mask = init_mask_from_bad_pix(datafile)
        if !isnothing(parsed_args["mask"])
            @info "external mask supplied: "*parsed_args["mask"]
            interpret_YAML_mask(mask, parsed_args["mask"])
        end
        
        #= Images
            -export all the images as individual, non bitshuffled h5 files with included
        =#
        @info "processing image files"
        remove!(data_list,"data_003444") #TODO REMOVE

        #write all the individual files and maintain the files.lst as we go
        open(output_folder*"files.lst","w") do fileslst
            for i in ProgressBar(1:length(data_list))
                dataset = data_list[i]
                length = size(datafile["entry/data/"*dataset])[3]
                start_image = read_attribute(datafile["entry/data/"*dataset], "image_nr_low")
            
                for j in (1:length)
                    current_image = start_image + j -1
                    image = datafile["entry/data/"*dataset][:,:,j]
                    #@info "Data record " * string(current_image) * " to " * output_folder * "image_" * string(current_image) * ".h5. Size: " * string(size(image))
                    write(fileslst, "image_"*string(current_image)*".h5\n")
                    h5open(output_folder*"image_"*string(current_image)*".h5", "w") do file
                        write(file, "data/data", image)
                        write(file, "data/mask", mask)
                    end

                end
            end
            
        end

    end
end

main()
#=
bp = open("bad_pixels.txt","w")
image = datafile["entry/data/data_001234"][:,:,1]
image = isequal(0xffffffff).(image)
for i in 1:size(image)[1]
    for j in 1:size(image)[1]
        if image[i,j] ==1
            write(bp, "- ["*string(i)*","*string(j)*"]\n")
        end
    end
end
close(bp)
size(isequal(0xffffffff).(image))
=#
>>>>>>> Stashed changes
