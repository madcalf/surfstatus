######################
# Requires
######################

# utilities
del                      = require 'del'
fs                       = require 'fs'
browsersync              = require 'browser-sync'

# gulp utilities
gulp                     = require 'gulp'
filter                   = require 'gulp-filter'
uglify                   = require 'gulp-uglify'
notify                   = require 'gulp-notify'
rsync                    = require 'gulp-rsync'
gzip                     = require 'gulp-gzip'
gutil                    = require 'gulp-util'
changed                  = require 'gulp-changed'

imagemin                 = require 'gulp-imagemin'

bower                    = require 'main-bower-files'

# task 'JS'
order                    = require 'gulp-order'
include                  = require 'gulp-include'

# task 'CSS'
cssnano                  = require 'gulp-cssnano'
concat                   = require 'gulp-concat'
sourcemaps               = require 'gulp-sourcemaps'
lost                     = require 'lost'
cssnext                  = require 'cssnext'
postcss                  = require 'gulp-postcss'
postcssimport            = require 'postcss-import'
postcssnested            = require 'postcss-nested'
postcssfocus             = require 'postcss-focus'
postcsspxtorem           = require 'postcss-pxtorem'
postcsscolorfunction     = require 'postcss-center'
postcsssimplevars        = require 'postcss-simple-vars'
postcsssimpleextend      = require 'postcss-simple-extend'

secrets                = require './data/secrets.json'

####################
# Paths
####################

paths =
  base:
    root : ''
    src  : './src'
    dist : './public'
    tmp  : './tmp'

paths.src =
  css    : paths.base.src + '/css'
  js     : paths.base.src + '/js'
  images : paths.base.src + '/images'

paths.dist =
  css    : paths.base.dist + '/css'
  js     : paths.base.dist + '/js'
  images : paths.base.dist + '/images'

####################
# Functions
####################

#### Error Handling
# (ref. https://gist.github.com/noahmiller/61699ad1b0a7cc65ae2d)
watching = false

# Command line option:
#  --fatal=[warning|error|off]
ERROR_LEVELS = ['error', 'warning']

# Return true if the given level is equal to or more severe than
# the configured fatality error level.
# If the fatalLevel is 'off', then this will always return false.
# Defaults the fatalLevel to 'error'.
isFatal = (level) ->
  ERROR_LEVELS.indexOf(level) <= ERROR_LEVELS.indexOf(fatalLevel || 'error')

# Handle an error based on its severity level.
# Log all levels, and exit the process for fatal levels.
# ref. http://stackoverflow.com/questions/21602332/catching-gulp-mocha-errors#answers
handleError = (level, error) ->
  gutil.log(error.message)
  # if isFatal(level)
  #   process.exit(1)
  if watching
    this.emit('end')
  else
    process.exit(1)

# Convenience handler for error-level errors.
onError = (error) -> handleError.call(this, 'error', error)
# Convenience handler for warning-level errors.
onWarning = (error) -> handleError.call(this, 'warning', error)

#### Deleting old files
deleteFolderRecursive = (path) ->
  if fs.existsSync(path)
    fs.readdirSync(path).forEach (file,index) ->
      curPath = path + "/" + file
      if fs.lstatSync(curPath).isDirectory()
        deleteFolderRecursive(curPath)
      else
        fs.unlinkSync(curPath)
    fs.rmdirSync(path)

####################
# Tasks
####################

gulp.task 'clean', ->
  deleteFolderRecursive(paths.base.dist)

gulp.task 'bower', ->
  gulp.src bower()
    .pipe filter('*.js')
    .pipe uglify()
    .pipe gulp.dest(paths.dist.js)
    .on('error', onError)

gulp.task 'js', ->

  gulp.src "#{paths.src.js}/**/[^_]*.{js,coffee}"
    .pipe order([
      "helpers.js",
      "surf-directions.js",
      "wave-canvas.js",
      "application.js"
    ])
    # .pipe changed(paths.dist.js)
    .pipe include().on('error', onError)
    .pipe concat('app.js')
    .pipe sourcemaps.init()
      .pipe uglify().on('error', onError)
    .pipe sourcemaps.write('maps')
    .pipe gulp.dest(paths.dist.js)
    # .pipe gzip({ append: true })
    # .pipe gulp.dest(paths.dist.js)
    .on('error', onError)

gulp.task 'css', ->
  postCSSProcessors = [
    postcssimport from: "#{paths.src.css}/app.css"
    postcssnested
    postcssfocus
    postcsscolorfunction
    postcsspxtorem
    postcsssimplevars
    postcsssimpleextend
    lost
    cssnext       compress: false, autoprefixer: { browsers: ['last 1 version'] }
  ]

  gulp.src "#{paths.src.css}/**/[^_]*.{css,scss}"
    .pipe concat('app.css')
    .pipe sourcemaps.init()
      .pipe postcss(postCSSProcessors).on('error', onError)
      .pipe cssnano(browsers: ['last 1 version'])
    .pipe sourcemaps.write('maps')
    .pipe gulp.dest(paths.dist.css)
    # .pipe gzip({ append: true })
    # .pipe gulp.dest(paths.dist.css)
    .on('error', onError)

gulp.task 'images', ->
  gulp.src("#{paths.src.images}/**/*.{gif,jpg,png}")
    .pipe changed(paths.dist.images)
    .pipe imagemin
    #   progressive: true,
    #   svgoPlugins: [removeViewBox: false],
      optimizationLevel: 3 # png
    .pipe gulp.dest(paths.dist.images)


gulp.task 'deploy', ->
  gulp.src(['./**/*', '!bower_components/**/*', '!node_modules/**/*'])
    .pipe rsync
      destination: '../home/deploy/'
      hostname: secrets[0].serverInfo.hostname
      username: secrets[0].serverInfo.username
      progress: true
      recursive: true
      time: true
      update: true
      compress: true

gulp.task 'browsersync', ->
  browsersync.use
    plugin: ->,
    hooks:
      'client:js': fs.readFileSync("./lib/closer.js", "utf-8")
  browsersync.init [paths.dist.css, paths.dist.js]

gulp.task 'watch', ['browsersync'], ->
  watching = true
  gulp.watch ["#{paths.base.src}/*.*", "#{paths.base.src}/data/**/*"], ['static-files']
  gulp.watch "#{paths.src.css}/**/*", ['css']
  gulp.watch "#{paths.src.js}/**/*.{js,coffee}", ['js']
  gulp.watch "#{paths.src.images}/**/*.{gif,jpg,png}", ['images']

gulp.task 'refresh', ['clean', 'build']
gulp.task 'build',   ['js', 'css', 'images']
gulp.task 'default', ['bower', 'refresh', 'watch']