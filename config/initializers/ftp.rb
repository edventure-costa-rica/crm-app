Trip.ftp_mkdir = true
Trip.ftp_root = '/srv/ftp/shared'
Trip.ftp_path = 'edventure/Reservaciones'
Trip.ftp_host = 'files.edventure.ha.cr'

if Rails.env == 'development'
  Trip.ftp_root = '/Volumes/Users/josh/Work/ed/ftp'
end
