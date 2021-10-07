using Logging

function interpret_YAML_mask(f_mask, filename)
    mask_data = YAML.load_file(filename)
    if haskey(mask_data, "rectangles")
        @info "Processing rectangles in YAML mask"
        compile_mask_rectangles!(f_mask, mask_data["rectangles"])
    end
    if haskey(mask_data, "circles")
        @info "Processing rings in YAML mask"

    end
    if haskey(mask_data, "pixels")
        @info "Processing pixels in YAML mask"
        compile_mask_pixels!(f_mask, mask_data["pixels"])
    end
end


function compile_mask_rectangles!(f_mask, f_mask_rectangles)
    for c in f_mask_rectangles
        for i = c[1]+1:c[3]+1
            for j = c[2]+1:c[4]+1
                f_mask[j,i] = 1
            end
        end
    end
end

function compile_mask_pixels!(f_mask, f_mask_pixels)
    for p in f_mask_pixels
        f_mask[p[1],p[2]] = 1
    end
end

function apply_mask!(f_image,f_mask)
    f_image_dims = size(f_image)
    for i = 1:f_image_dims[1]
        for j = 1:f_image_dims[2]
            if f_mask[i,j] == 1
                f_image[i,j] = 0
            end
        end
    end
end

function init_mask(imagedata)
    return trues(size(imagedata))
end

"""
    init_mask_from_bad_pix(datafile)

Take the .h5 master file as input, extract the pixel mask, and convert it to a bitarray.
"""
function init_mask_from_bad_pix(datafile)
    convert(Array{UInt8},!=(0).(datafile["/entry/instrument/detector/detectorSpecific/pixel_mask"][:,:]))
end

#function generate_mask(imagedata)