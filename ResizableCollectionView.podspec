Pod::Spec.new do |s|
  s.name             = "ResizableCollectionView"
  s.version          = "1.0.3"
  s.summary          = "ResizableCollectionView is a library to change the number of columns by pinch in / out."
  s.description      = <<-DESC
                       ResizableCollectionView is a library to change the number of columns by pinch in / out.
                       DESC
  s.homepage         = "https://github.com/chidori-app/ResizableCollectionView"
  s.license          = 'MIT'
  s.author           = { "ioka" => "hit0apps@gmail.com" }
  s.source           = { :git => "https://github.com/chidori-app/ResizableCollectionView.git", :tag => s.version.to_s }
  s.screenshots  = "https://raw.githubusercontent.com/chidori-app/ResizableCollectionView/master/imgs/ResizableCollectionView.gif"
  s.social_media_url = "https://twitter.com/hitting1024"
  s.platform     = :ios, "8.0"
  s.requires_arc = true
  s.source_files = "ResizableCollectionView/*.swift"
end
