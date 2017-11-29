require 'Datavyu_API.rb'
require 'date'

###################################################################################
# USER EDITABLE SECTION.  PLEASE PLACE YOUR SCRIPT BETWEEN BEGIN AND END BELOW.
###################################################################################

begin

    filedir = "/Volumes/Experiments/color_crayola/datavyu/"
    filenames = Dir.new(filedir).entries


    dir = File.expand_path("~/Documents/repo/crayola_color/data")
    out_file = File.new(dir + "/printed_data.csv", "w")

    out_file.syswrite ("subj,sex,age,pilot,phase,phase_onset,phase_offset,stimulus,stim_onset,stim_offset,response,response_onset,response_offset,\n")

    DATE_FORMATS = ['%m/%d/%Y', '%m/%d/%y']

    def parse_or_nil(date_str)
        parsed_date = nil
        DATE_FORMATS.each do |f|
            parsed_date ||= DateTime.strptime(date_str, f) rescue nil
        end
        parsed_date
    end

    for file in filenames
        if file.include?(".opf") and file[0].chr != '.' and file != 'template.opf'

            puts "LOADING DATABASE: " + filedir+file
            $db,proj = load_db(filedir+file)
            puts "SUCCESSFULLY LOADED"

            id = getVariable("id")
            phase = getVariable("phase")
            prompt = getVariable("prompt")
            response = getVariable("response")

            dot = id.cells.first.dot
            next if parse_or_nil(dot).nil? 
            for idcell in id.cells
                # print idcell.dot.to_s + " - " + idcell.dob.to_s + " = "
                age = (((parse_or_nil(idcell.dot) - parse_or_nil(idcell.dob)).to_f)/365).round(1)
                # print age
                for phasecell in phase.cells
                    for promptcell in prompt.cells
                        for responsecell in response.cells
                            if promptcell.onset >= phasecell.onset and promptcell.offset <= phasecell.offset
                                if responsecell.onset >= promptcell.onset and responsecell.offset <= promptcell.offset
                                    out_file.syswrite (idcell.subj + "," + idcell.sex + "," + age.to_s + "," + idcell.pilot + "," + 
                                        phasecell.phase + "," + phasecell.onset.to_s + "," + phasecell.offset.to_s + "," + 
                                        promptcell.prompt + "," + promptcell.onset.to_s + "," + promptcell.offset.to_s + "," + 
                                        "\"#{responsecell.response}\""  + "," + responsecell.onset.to_s + "," + responsecell.offset.to_s + "," + "\n")
                                end
                            end
                        end
                    end
                end
            end
        end
        puts "done"
    end
end

