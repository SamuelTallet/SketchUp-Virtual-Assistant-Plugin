# Virtual Assistant extension for SketchUp 2017 or newer.
# Copyright: © 2019 Samuel Tallet <samuel.tallet arobase gmail.com>
# 
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3.0 of the License, or
# (at your option) any later version.
# 
# If you release a modified version of this program TO THE PUBLIC,
# the GPL requires you to MAKE THE MODIFIED SOURCE CODE AVAILABLE
# to the program's users, UNDER THE GPL.
# 
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
# General Public License for more details.
# 
# Get a copy of the GPL here: https://www.gnu.org/licenses/gpl.html

raise 'The VAT plugin requires at least Ruby 2.2.0 or SketchUp 2017.'\
  unless RUBY_VERSION.to_f >= 2.2 # SketchUp 2017 includes Ruby 2.2.4.

require 'sketchup'
require 'vat/html_dialogs'
require 'vat/memory'
require 'vat/model'
require 'vat/entities'
require 'vat/shapes'

# VAT plugin namespace.
module VAT

  # Chat Room.
  class ChatRoom

    attr_reader :html_dialog

    # Initializes Chat Room...
    def initialize

      @html_dialog = UI::HtmlDialog.new(

        dialog_title:    TRANSLATE['Virtual Assistant Chat Room'],
        preferences_key: 'VAT Chat Room',
        scrollable:      true,
        width:           500,
        height:          400,
        min_width:       500,
        min_height:      400

      )

      @html_dialog.set_html(HTMLDialogs.merge(

        # Note: Paths below are relative to `HTMLDialogs::DIR`.

        document: 'chat-room.rhtml',

        scripts: [
          'lib/auto-complete.min.js',
          'lib/compromise.min.js',
          'chat-room.js'
        ],

        styles: [
          'lib/auto-complete.css',
          'chat-room.css'
        ]

      ))

      @html_dialog.add_action_callback('getUserName') do

        if Sketchup.platform == :platform_win

          @html_dialog.execute_script('VAT.userName="' + ENV['USERNAME'] + '"')

        else # if Sketchup.platform == :platform_osx

          @html_dialog.execute_script('VAT.userName="' + ENV['USER'] + '"')

        end

      end

      @html_dialog.add_action_callback('loadMemory') do

        @html_dialog.execute_script('VAT.memory=' + Memory.load.to_json)

      end

      @html_dialog.add_action_callback('openModel') do

        if Model.open

          @html_dialog.execute_script("VAT.botSay(VAT.synonym('It\\'s done.'))")

        else

          @html_dialog.execute_script("VAT.botSay('Something goes wrong!')")

        end

      end

      @html_dialog.add_action_callback('cleanModel') do

        Model.clean

      end

      @html_dialog.add_action_callback('selectFirstEntity') do

        if Entities.select_first_entity

          @html_dialog.execute_script("VAT.botSay(VAT.synonym('It\\'s done.'))")

        else

          @html_dialog.execute_script("VAT.botSay('No entity found!')")

        end

      end

      @html_dialog.add_action_callback('selectFirstGroup') do

        if Entities.select_first_group

          @html_dialog.execute_script("VAT.botSay(VAT.synonym('It\\'s done.'))")

        else

          @html_dialog.execute_script("VAT.botSay('No group found!')")

        end

      end

      @html_dialog.add_action_callback('selectGroupsNamed') do |_context, name|

        if Entities.select_groups_named(name)

          @html_dialog.execute_script("VAT.botSay(VAT.synonym('It\\'s done.'))")

        else

          @html_dialog.execute_script("VAT.botSay('No matching group!')")

        end

      end

      @html_dialog.add_action_callback('selectFirstComponent') do

        if Entities.select_first_component

          @html_dialog.execute_script("VAT.botSay(VAT.synonym('It\\'s done.'))")

        else

          @html_dialog.execute_script("VAT.botSay('No component found!')")

        end

      end

      @html_dialog.add_action_callback('selectComponentsNamed') do |_context, name|

        if Entities.select_components_named(name)

          @html_dialog.execute_script("VAT.botSay(VAT.synonym('It\\'s done.'))")

        else

          @html_dialog.execute_script("VAT.botSay('No matching component!')")

        end

      end

      @html_dialog.add_action_callback('moveSelection') do

        parameters = UI.inputbox(
          ['X axis', 'Y axis', 'Z axis'], # Prompts
          ['1m', '1m', '1m'], # Defaults
          NAME # Title
        )

        return if parameters == false

        status = Entities.move_selection(
          parameters[0].to_l, parameters[1].to_l, parameters[2].to_l
        )

        if status == true

          @html_dialog.execute_script("VAT.botSay(VAT.synonym('It\\'s done.'))")

        elsif status.nil?

          @html_dialog.execute_script("VAT.botSay('Nothing is selected!')")

        else # if status == false

          @html_dialog.execute_script("VAT.botSay('No grouponent found!')")

        end

      end

      @html_dialog.add_action_callback('rotateSelection') do |_context, angle|

        status = Entities.rotate_selection(angle.to_i)

        if status == true

          @html_dialog.execute_script("VAT.botSay(VAT.synonym('It\\'s done.'))")

        elsif status.nil?

          @html_dialog.execute_script("VAT.botSay('Nothing is selected!')")

        else # if status == false

          @html_dialog.execute_script("VAT.botSay('No grouponent found!')")

        end

      end

      @html_dialog.add_action_callback('scaleSelection') do |_context, scale|

        status = Entities.scale_selection(scale.to_f)

        if status == true

          @html_dialog.execute_script("VAT.botSay(VAT.synonym('It\\'s done.'))")

        elsif status.nil?

          @html_dialog.execute_script("VAT.botSay('Nothing is selected!')")

        else # if status == false

          @html_dialog.execute_script("VAT.botSay('No grouponent found!')")

        end

      end

      @html_dialog.add_action_callback('renameSelection') do |_context, name|

        status = Entities.rename_selection(name)

        if status == true

          @html_dialog.execute_script("VAT.botSay(VAT.synonym('It\\'s done.'))")

        elsif status.nil?

          @html_dialog.execute_script("VAT.botSay('Nothing is selected!')")

        else # if status == false

          @html_dialog.execute_script("VAT.botSay('No grouponent found!')")

        end

      end

      @html_dialog.add_action_callback('copySelection') do |_context, name|

        status = Entities.copy_selection(name)

        if status == true

          @html_dialog.execute_script("VAT.botSay(VAT.synonym('It\\'s done.'))")

        elsif status.nil?

          @html_dialog.execute_script("VAT.botSay('Nothing is selected!')")

        else # if status == false

          @html_dialog.execute_script("VAT.botSay('No grouponent found!')")

        end

      end

      @html_dialog.add_action_callback('clearSelection') do

        Entities.clear_selection

      end

      @html_dialog.add_action_callback('eraseSelectedEntities') do

        if Entities.erase_selected_entities

          @html_dialog.execute_script("VAT.botSay(VAT.synonym('It\\'s done.'))")

        else

          @html_dialog.execute_script("VAT.botSay('Nothing is selected!')")

        end

      end

      @html_dialog.add_action_callback('sendAction') do |_context, action|

        if Sketchup.send_action(action)

          @html_dialog.execute_script("VAT.botSay(VAT.synonym('It\\'s done.'))")

        else

          @html_dialog.execute_script("VAT.botSay('No matching action!')")

        end

      end

      @html_dialog.add_action_callback('drawBox') do

        parameters = UI.inputbox(
          ['Width', 'Depth', 'Height'], # Prompts
          ['1m', '1m', '1m'], # Defaults
          NAME # Title
        )

        if parameters.is_a?(Array)

          Shapes.create_box(
            parameters[0].to_l,
            parameters[1].to_l,
            parameters[2].to_l
          )

          @html_dialog.execute_script("VAT.botSay(VAT.synonym('It\\'s done.'))")

        end

      end

      @html_dialog.add_action_callback('drawCone') do

        parameters = UI.inputbox(
          ['Radius', 'Height'], # Prompts
          ['1m', '1m'], # Defaults
          NAME # Title
        )

        if parameters.is_a?(Array)

          Shapes.create_cone(
            parameters[0].to_l,
            parameters[1].to_l
          )

          @html_dialog.execute_script("VAT.botSay(VAT.synonym('It\\'s done.'))")

        end

      end

      @html_dialog.add_action_callback('drawCylinder') do

        parameters = UI.inputbox(
          ['Radius', 'Height'], # Prompts
          ['1m', '1m'], # Defaults
          NAME # Title
        )

        if parameters.is_a?(Array)

          Shapes.create_cylinder(
            parameters[0].to_l,
            parameters[1].to_l
          )

          @html_dialog.execute_script("VAT.botSay(VAT.synonym('It\\'s done.'))")

        end

      end

      @html_dialog.add_action_callback('drawPrism') do

        parameters = UI.inputbox(
          ['Radius', 'Height', 'Sides'], # Prompts
          ['1m', '1m', '6'], # Defaults
          NAME # Title
        )

        if parameters.is_a?(Array)

          Shapes.create_prism(
            parameters[0].to_l,
            parameters[1].to_l,
            parameters[2].to_i
          )

          @html_dialog.execute_script("VAT.botSay(VAT.synonym('It\\'s done.'))")

        end

      end

      @html_dialog.add_action_callback('drawPyramid') do

        parameters = UI.inputbox(
          ['Radius', 'Height', 'Sides'], # Prompts
          ['1m', '1m', '4'], # Defaults
          NAME # Title
        )

        if parameters.is_a?(Array)

          Shapes.create_pyramid(
            parameters[0].to_l,
            parameters[1].to_l,
            parameters[2].to_i
          )

          @html_dialog.execute_script("VAT.botSay(VAT.synonym('It\\'s done.'))")

        end

      end

      @html_dialog.add_action_callback('drawSphere') do

        parameters = UI.inputbox(
          ['Radius'], # Prompts
          ['1m'], # Defaults
          NAME # Title
        )

        if parameters.is_a?(Array)

          Shapes.create_sphere(
            parameters[0].to_l
          )

          @html_dialog.execute_script("VAT.botSay(VAT.synonym('It\\'s done.'))")

        end

      end

      @html_dialog.add_action_callback('writeText') do |_context, text|

        if Entities.write_text(text)

          @html_dialog.execute_script("VAT.botSay(VAT.synonym('It\\'s done.'))")

        else

          @html_dialog.execute_script("VAT.botSay('Something goes wrong!')")

        end

      end

      @html_dialog.add_action_callback('searchPlugin') do |_context, topics|

        UI.openURL(
          'https://sketchucation.com/pluginstore?search=' + CGI::escape(topics)
        )

      end

      @html_dialog.add_action_callback('saveMemory') do |_context, memory|

        Memory.save(memory)

      end

      @html_dialog.add_action_callback('closeChatRoom') do

        @html_dialog.close

      end

      @html_dialog.center

    end

  end

end
