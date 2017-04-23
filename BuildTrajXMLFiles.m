%%
%this function builds an xml file describing the letter trajectories, 
%used by gestureIK program to build trajectories for IK
function BuildTrajXMLFiles(outSSTrajDir)
    tmpDirRes = dir(outSSTrajDir);
    letterDirs = {tmpDirRes([tmpDirRes.isdir]).name};
    letterDirs(1:2) = []; %ignore . and ..
    clear tmpDirRes;
    for dirIdx = 1:size(letterDirs,2)
        ltrDir = char(letterDirs(1,dirIdx));
        ltrFullDir = [outSSTrajDir,ltrDir];
        uLocs = strfind(ltrDir,'_');  %use uLocs(1)+1 for letter
        ltr = ltrDir(uLocs(1)+1);
        xmlFileName = [ltrDir,'.xml'];
        symbolXMLFileName = [ltrFullDir,'/',xmlFileName];
        disp(xmlFileName);
        disp(symbolXMLFileName);
      
        %get listing of xml files existing in ltrDir - remove ltrDir.xml
        tmpLDirRes = dir(ltrFullDir);
        symbolDirs = {tmpLDirRes(~[tmpLDirRes.isdir]).name};
        %remove xml listing file from these dirs - don't want to use this
        %as traj source if rerun
        symbolDirs = symbolDirs(~strcmp(symbolDirs, xmlFileName));  
        numExamples = size(symbolDirs,2);
        
        %read every letter file in ltrDir, build xml file describing each
        docNode = com.mathworks.xml.XMLUtils.createDocument('letterData');

        letter_node = docNode.createElement('letter');
        letter_text = docNode.createTextNode(ltr);
        letter_node.appendChild(letter_text);
        docNode.getDocumentElement.appendChild(letter_node);

        sym_count_node = docNode.createElement('symbolExampleCounts');
        sym_count_text = docNode.createTextNode(num2str(numExamples));
        sym_count_node.appendChild(sym_count_text);
        docNode.getDocumentElement.appendChild(sym_count_node);
        %added to xml so that gestureIK knows to process these files 
        %as x,y, velx, vely files instead of x,y,time of omniglot
        sym_type_node = docNode.createElement('symbolType');
        sym_type_text = docNode.createTextNode('1');
        sym_type_node.appendChild(sym_type_text);
        docNode.getDocumentElement.appendChild(sym_type_node); 

        symbolNode = docNode.createElement('symbols');
        for r=1:numExamples % for each alphabet entry save each generated letter (symbol)
            trajCSVFName = symbolDirs(1,r);
            trajCSVFileName = strcat(ltrFullDir,'/',trajCSVFName);
            %set # of trajectories - always 1 for these examples
            example_node = docNode.createElement('symbol');        
            traj_count_node = docNode.createElement('trajCounts'); 
            traj_count_text = docNode.createTextNode('1');
            traj_count_node.appendChild(traj_count_text);
            example_node.appendChild(traj_count_node);
            
            traj_name_node = docNode.createElement('trajectory'); 
            traj_name_text = docNode.createTextNode(trajCSVFileName);
            traj_name_node.appendChild(traj_name_text);
            example_node.appendChild(traj_name_node);


            %write symbol XML file with # of trajectories and names of each
            %trajectory csv file
            %write to file
            symbolNode.appendChild(example_node);
        end      %for each symbol representation for a particular letter
        docNode.getDocumentElement.appendChild(symbolNode);
        xmlwrite(symbolXMLFileName,docNode);    

    end
end