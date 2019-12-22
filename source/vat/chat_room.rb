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

      @html_dialog.add_action_callback('cleanModel') do

        Model.clean

      end

      @html_dialog.add_action_callback('drawBox') do |_context, attributes|

        Shapes.create_box(
          attributes['width'].to_l,
          attributes['depth'].to_l,
          attributes['height'].to_l
        )

      end

      @html_dialog.add_action_callback('drawCone') do |_context, attributes|

        Shapes.create_cone(
          attributes['radius'].to_l,
          attributes['height'].to_l
        )

      end

      @html_dialog.add_action_callback('drawCylinder') do |_context, attributes|

        Shapes.create_cylinder(
          attributes['radius'].to_l,
          attributes['height'].to_l
        )

      end

      @html_dialog.add_action_callback('drawPrism') do |_context, attributes|

        Shapes.create_prism(
          attributes['radius'].to_l,
          attributes['height'].to_l,
          attributes['num_sides'].to_i
        )

      end

      @html_dialog.add_action_callback('drawPyramid') do |_context, attributes|

        Shapes.create_pyramid(
          attributes['radius'].to_l,
          attributes['height'].to_l,
          attributes['num_sides'].to_i
        )

      end

      @html_dialog.add_action_callback('drawSphere') do |_context, attributes|

        Shapes.create_sphere(
          attributes['radius'].to_l
        )

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
