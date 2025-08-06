// Configure your import map in config/importmap.rb. Read more: https://github.com/rails/importmap-rails
import "@hotwired/turbo-rails"
import "controllers"
import { MarksmithController, ListContinuationController } from '@avo-hq/marksmith'
import { application } from "controllers/application"

application.register('marksmith', MarksmithController)
application.register('list-continuation', ListContinuationController)
