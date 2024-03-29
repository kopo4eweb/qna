// This file is automatically compiled by Webpack, along with any other files
// present in this directory. You're encouraged to place your actual application logic in
// a relevant structure within app/javascript and only use these pack files to reference
// that code so it'll be compiled.

import Rails from "@rails/ujs"
import Turbolinks from "turbolinks"
import * as ActiveStorage from "@rails/activestorage"
import "channels"
require("jquery")
require("@nathanvda/cocoon")
require("bootstrap")
require("./answers.js")
require("./questions.js")
require("./direct_uploads.js")
require("./vote.js")
require("./comments.js")

Rails.start()
Turbolinks.start()
ActiveStorage.start()

import $ from 'jquery'
window.jQuery = $;
window.$ = $;

import "../stylesheets/all.sass"