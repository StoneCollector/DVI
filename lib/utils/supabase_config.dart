class SupabaseConfig {
  static const String projectUrl = 'https://zyozigpldjruomhqaqjy.supabase.co';
  static const String anonKey =
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Inp5b3ppZ3BsZGpydW9taHFhcWp5Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjkwMDIyNzcsImV4cCI6MjA4NDU3ODI3N30.FM-bzBD-zN1soAFNGKTemhPYpju6ytARrISrBwTtDKA';
  static const String bucketName = 'carasol';

  // Helper method to get public URL for images
  static String getImageUrl(String fileName) {
    final url = '$projectUrl/storage/v1/object/public/$bucketName/$fileName';
    print('Loading image from Supabase: $url');
    return url;
  }
}
