# Copyright (c) 2018 Cisco and/or its affiliates.
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at:
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

##############################################################################
# API
##############################################################################
function(vpp_generate_api_c_header file)
  set (output_name ${CMAKE_CURRENT_BINARY_DIR}/${file}.h)
  get_filename_component(output_dir ${output_name} DIRECTORY)
  add_custom_command (OUTPUT ${output_name}
    COMMAND mkdir -p ${output_dir}
    COMMAND ${CMAKE_SOURCE_DIR}/tools/vppapigen/vppapigen
    ARGS --includedir ${CMAKE_SOURCE_DIR} --input ${CMAKE_CURRENT_SOURCE_DIR}/${file} --output ${output_name}
    DEPENDS ${CMAKE_CURRENT_SOURCE_DIR}/${file}
    COMMENT "Generating API header ${output_name}"
  )
endfunction()

function(vpp_generate_api_json_header file dir)
  set (output_name ${CMAKE_CURRENT_BINARY_DIR}/${file}.json)
  get_filename_component(output_dir ${output_name} DIRECTORY)
  add_custom_command (OUTPUT ${output_name}
    COMMAND mkdir -p ${output_dir}
    COMMAND ${CMAKE_SOURCE_DIR}/tools/vppapigen/vppapigen
    ARGS --includedir ${CMAKE_SOURCE_DIR} --input ${CMAKE_CURRENT_SOURCE_DIR}/${file} JSON --output ${output_name}
    DEPENDS ${CMAKE_CURRENT_SOURCE_DIR}/${file}
    COMMENT "Generating API header ${output_name}"
  )
  install(FILES ${output_name} DESTINATION share/vpp/api/${dir}/)
endfunction()

##############################################################################
# generate the .h and .json files for a .api file
#  @param file - the name of the .api
#  @param dir  - the install directory under ROOT/share/vpp/api to place the
#                generated .json file
##############################################################################
function(vpp_generate_api_header file dir)
    vpp_generate_api_c_header (${file})
    vpp_generate_api_json_header (${file} ${dir})
endfunction()

function(vpp_add_api_files target)
  unset(header_files)
  foreach(file ${ARGN})
    vpp_generate_api_header (${file} core)
    list (APPEND header_files ${file}.h ${file}.json)
  endforeach()
  add_custom_target(${target} DEPENDS ${header_files})
endfunction()

add_custom_target(api_headers
  DEPENDS vlibmemory_api_headers vnet_api_headers vpp_api_headers
)

