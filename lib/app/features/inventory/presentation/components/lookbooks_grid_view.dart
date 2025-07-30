import 'package:flutter/material.dart';
import '../../domain/entities/lookbook.dart';

class LookbooksGridView extends StatelessWidget {
  final List<Lookbook> lookbooks;
  final Function(String) onLookbookTap;
  final Function(String) onLookbookDelete;

  const LookbooksGridView({
    super.key,
    required this.lookbooks,
    required this.onLookbookTap,
    required this.onLookbookDelete,
  });

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 0.85,
      ),
      itemCount: lookbooks.length,
      itemBuilder: (context, index) {
        final lookbook = lookbooks[index];
        return _buildLookbookCard(context, lookbook);
      },
    );
  }

  Widget _buildLookbookCard(BuildContext context, Lookbook lookbook) {
    return GestureDetector(
      onTap: () => onLookbookTap(lookbook.id),
      onLongPress: () => _showOptionsBottomSheet(context, lookbook),
      child: Card(
        elevation: 3,
        shadowColor: Colors.black.withOpacity(0.1),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.white,
                Colors.grey[50]!,
              ],
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildImageSection(lookbook),
              _buildInfoSection(context, lookbook),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImageSection(Lookbook lookbook) {
    return Expanded(
      flex: 3,
      child: Container(
        margin: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: Colors.grey[100],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: _buildImageGrid(lookbook),
        ),
      ),
    );
  }

  Widget _buildImageGrid(Lookbook lookbook) {
    if (lookbook.images.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.collections_bookmark_outlined,
              size: 32,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 4),
            Text(
              'No Images',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[500],
              ),
            ),
          ],
        ),
      );
    }

    if (lookbook.images.length == 1) {
      return Image.network(
        lookbook.images[0],
        fit: BoxFit.cover,
        width: double.infinity,
        height: double.infinity,
        errorBuilder: (context, error, stackTrace) => _buildPlaceholder(),
      );
    }

    // Grid layout for multiple images
    return GridView.builder(
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 2,
        mainAxisSpacing: 2,
      ),
      itemCount: lookbook.images.length > 4 ? 4 : lookbook.images.length,
      itemBuilder: (context, index) {
        if (index == 3 && lookbook.images.length > 4) {
          return _buildMoreImagesOverlay(lookbook.images.length - 3);
        }
        
        return Image.network(
          lookbook.images[index],
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) => _buildPlaceholder(),
        );
      },
    );
  }

  Widget _buildMoreImagesOverlay(int moreCount) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.7),
      ),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.add,
              color: Colors.white,
              size: 16,
            ),
            Text(
              '+$moreCount',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      color: Colors.grey[200],
      child: Icon(
        Icons.image_outlined,
        color: Colors.grey[400],
        size: 24,
      ),
    );
  }

  Widget _buildInfoSection(BuildContext context, Lookbook lookbook) {
    return Expanded(
      flex: 2,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title and product count
            Row(
              children: [
                Expanded(
                  child: Text(
                    lookbook.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                      color: Colors.black87,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.blue[50],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.blue[200]!),
                  ),
                  child: Text(
                    '${lookbook.numberOfProducts}',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: Colors.blue[700],
                    ),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 4),
            
            // Description (if available)
            if (lookbook.description != null && lookbook.description!.isNotEmpty) ...[
              Text(
                lookbook.description!,
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.grey[600],
                  height: 1.2,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
            ],
            
            const Spacer(),
            
            // Updated time
            Row(
              children: [
                Icon(
                  Icons.access_time,
                  size: 10,
                  color: Colors.grey[500],
                ),
                const SizedBox(width: 2),
                                 Expanded(
                   child: Text(
                     _formatRelativeTime(lookbook.updatedAt),
                     style: TextStyle(
                       fontSize: 10,
                       color: Colors.grey[500],
                     ),
                   ),
                 ),
                Icon(
                  Icons.arrow_forward_ios,
                  size: 10,
                  color: Colors.grey[400],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showOptionsBottomSheet(BuildContext context, Lookbook lookbook) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            
            Text(
              lookbook.name,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 20),
            
            ListTile(
              leading: const Icon(Icons.open_in_new, color: Colors.blue),
              title: const Text('Open'),
              onTap: () {
                Navigator.pop(context);
                onLookbookTap(lookbook.id);
              },
            ),
            
            ListTile(
              leading: const Icon(Icons.share, color: Colors.green),
              title: const Text('Share'),
              onTap: () {
                Navigator.pop(context);
                _shareLookbook(lookbook);
              },
            ),
            
            ListTile(
              leading: const Icon(Icons.edit, color: Colors.orange),
              title: const Text('Edit'),
              onTap: () {
                Navigator.pop(context);
                // TODO: Implement edit functionality
              },
            ),
            
            ListTile(
              leading: const Icon(Icons.delete, color: Colors.red),
              title: const Text('Delete'),
              onTap: () {
                Navigator.pop(context);
                _showDeleteConfirmation(context, lookbook);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context, Lookbook lookbook) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Lookbook'),
        content: Text(
          'Are you sure you want to delete "${lookbook.name}"? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              onLookbookDelete(lookbook.id);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _shareLookbook(Lookbook lookbook) {
    // TODO: Implement share functionality
    print('Sharing lookbook: ${lookbook.name}');
  }

  String _formatRelativeTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }
} 