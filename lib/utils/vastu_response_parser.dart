/// Parser for Vastu AI responses to extract structured data
class VastuResponseParser {
  static ParsedVastuResponse parse(String text) {
    final cleaned = text.trim();
    
    // Extract overall score
    int overallScore = 0;
    final scoreMatch = RegExp(r'(\d+)\s*/\s*100', caseSensitive: false).firstMatch(cleaned);
    if (scoreMatch != null) {
      overallScore = int.tryParse(scoreMatch.group(1) ?? '0') ?? 0;
    }

    // Extract directional analysis - handle numbered lists
    final directions = <DirectionInfo>[];
    
    // Try to find the Directional Analysis section
    final dirSectionMatch = RegExp(
      r'2\.\s*Directional\s*Analysis[:\s]*\n(.*?)(?=\n\s*3\.|$)',
      caseSensitive: false,
      dotAll: true,
    ).firstMatch(cleaned);
    
    // Also try without the "2." prefix
    final dirSectionMatch2 = dirSectionMatch == null 
        ? RegExp(
            r'Directional\s*Analysis[:\s]*\n(.*?)(?=\n\s*(?:3\.|Room\s*Analysis|Critical|Positive|Recommendation|$))',
            caseSensitive: false,
            dotAll: true,
          ).firstMatch(cleaned)
        : null;
    
    final finalDirMatch = dirSectionMatch ?? dirSectionMatch2;
    if (finalDirMatch != null) {
      final dirSection = finalDirMatch.group(1) ?? '';
      // Match numbered items like "1. Northeast: description"
      final dirItemPattern = RegExp(
        r'\d+\.\s*(North|Northeast|East|Southeast|South|Southwest|West|Northwest|North-East|South-East|South-West|North-West)[:\s]+(.+?)(?=\n\s*\d+\.|$)',
        caseSensitive: false,
        dotAll: true,
      );
      
      final dirMatches = dirItemPattern.allMatches(dirSection);
      for (var match in dirMatches) {
        final dirName = _normalizeDirection(match.group(1) ?? '');
        final description = match.group(2)?.trim() ?? '';
        if (dirName.isNotEmpty && description.isNotEmpty) {
          final hasIssue = _hasIssue(description);
          directions.add(DirectionInfo(
            direction: dirName,
            description: description,
            hasIssue: hasIssue,
          ));
        }
      }
    }
    
    // Fallback: try the original pattern if nothing found
    if (directions.isEmpty) {
      final directionPattern = RegExp(
        r'(?:^|\n)\s*(?:[-•*]?\s*)?(North|Northeast|East|Southeast|South|Southwest|West|Northwest|North-East|South-East|South-West|North-West)[:\-]\s*(.+?)(?=\n\s*(?:North|Northeast|East|Southeast|South|Southwest|West|Northwest|North-East|South-East|South-West|North-West|Overall|Directional|Room|Critical|Positive|Recommendation|$))',
        caseSensitive: false,
        dotAll: true,
      );
      
      final directionMatches = directionPattern.allMatches(cleaned);
      for (var match in directionMatches) {
        final dirName = _normalizeDirection(match.group(1) ?? '');
        final description = match.group(2)?.trim() ?? '';
        if (dirName.isNotEmpty && description.isNotEmpty && 
            !directions.any((d) => d.direction == dirName)) {
          final hasIssue = _hasIssue(description);
          directions.add(DirectionInfo(
            direction: dirName,
            description: description,
            hasIssue: hasIssue,
          ));
        }
      }
    }

    // Extract room analysis - handle numbered lists
    final rooms = <RoomInfo>[];
    
    // Try to find the Room Analysis section
    final roomSectionMatch = RegExp(
      r'3\.\s*Room\s*Analysis[:\s]*\n(.*?)(?=\n\s*4\.|$)',
      caseSensitive: false,
      dotAll: true,
    ).firstMatch(cleaned);
    
    // Also try without the "3." prefix
    final roomSectionMatch2 = roomSectionMatch == null
        ? RegExp(
            r'Room\s*Analysis[:\s]*\n(.*?)(?=\n\s*(?:4\.|Critical|Positive|Recommendation|$))',
            caseSensitive: false,
            dotAll: true,
          ).firstMatch(cleaned)
        : null;
    
    final finalRoomMatch = roomSectionMatch ?? roomSectionMatch2;
    if (finalRoomMatch != null) {
      final roomSection = finalRoomMatch.group(1) ?? '';
      // Match numbered items like "1. Entrance: 9/10 - description"
      final roomItemPattern = RegExp(
        r'\d+\.\s*([A-Za-z\s]+(?:Bedroom|Kitchen|Pooja|Puja|Bathroom|Toilet|Living|Dining|Room|Area|Entrance))[:\s]+.*?(\d+)\s*/\s*10[:\s]*-?\s*(.+?)(?=\n\s*\d+\.|$)',
        caseSensitive: false,
        dotAll: true,
      );
      
      final roomMatches = roomItemPattern.allMatches(roomSection);
      for (var match in roomMatches) {
        final roomName = match.group(1)?.trim() ?? '';
        final scoreStr = match.group(2);
        final description = match.group(3)?.trim() ?? '';
        
        int score = 0;
        if (scoreStr != null) {
          score = int.tryParse(scoreStr) ?? 0;
        }
        
        if (roomName.isNotEmpty && score > 0) {
          rooms.add(RoomInfo(
            name: roomName,
            score: score,
            description: description.isNotEmpty ? description : 'No description available',
          ));
        }
      }
    }
    
    // Fallback: try the original pattern if nothing found
    if (rooms.isEmpty) {
      final roomPattern = RegExp(
        r'([A-Za-z\s]+(?:Bedroom|Kitchen|Pooja|Puja|Bathroom|Toilet|Living|Dining|Room|Area|Entrance))[:\-].*?(?:(\d+)\s*/\s*10|(\d+)\s*/\s*100|score[:\s]*(\d+))',
        caseSensitive: false,
      );
      
      final roomMatches = roomPattern.allMatches(cleaned);
      for (var match in roomMatches) {
        final roomName = match.group(1)?.trim() ?? '';
        final score10 = match.group(2);
        final score100 = match.group(3);
        final scoreOnly = match.group(4);
        
        int score = 0;
        if (score10 != null) {
          score = int.tryParse(score10) ?? 0;
        } else if (score100 != null) {
          score = (int.tryParse(score100) ?? 0) ~/ 10;
        } else if (scoreOnly != null) {
          score = int.tryParse(scoreOnly) ?? 0;
          if (score > 10) score = score ~/ 10;
        }
        
        if (roomName.isNotEmpty && score > 0) {
          // Extract description
          final descStart = match.end;
          final nextMatch = roomPattern.firstMatch(cleaned.substring(descStart));
          final descEnd = nextMatch?.start ?? cleaned.length;
          final description = cleaned.substring(descStart, descEnd).trim();
          
          if (!rooms.any((r) => r.name == roomName)) {
            rooms.add(RoomInfo(
              name: roomName,
              score: score,
              description: description.isNotEmpty ? description : 'No description available',
            ));
          }
        }
      }
    }

    // Extract critical issues
    final issues = <String>[];
    final issueSectionMatch = RegExp(
      r'4\.\s*Critical\s*Issues[:\s]*\n(.*?)(?=\n\s*5\.|$)',
      caseSensitive: false,
      dotAll: true,
    ).firstMatch(cleaned);
    
    // Also try without number prefix
    final issueSectionMatch2 = issueSectionMatch == null
        ? RegExp(
            r'Critical\s*Issues[:\s]*\n(.*?)(?=\n\s*(?:5\.|Positive|Recommendation|$))',
            caseSensitive: false,
            dotAll: true,
          ).firstMatch(cleaned)
        : null;
    
    final finalIssueMatch = issueSectionMatch ?? issueSectionMatch2;
    if (finalIssueMatch != null) {
      final issueSection = finalIssueMatch.group(1) ?? '';
      issues.addAll(_extractListItems(issueSection));
    } else {
      final issueSection = _extractSection(cleaned, ['Critical Issues', 'Issues', 'Vastu Defects', 'Problems']);
      if (issueSection.isNotEmpty) {
        issues.addAll(_extractListItems(issueSection));
      }
    }

    // Extract positive aspects
    final positiveAspects = <String>[];
    final positiveSectionMatch = RegExp(
      r'5\.\s*Positive\s*Aspects[:\s]*\n(.*?)(?=\n\s*6\.|$)',
      caseSensitive: false,
      dotAll: true,
    ).firstMatch(cleaned);
    
    // Also try without number prefix
    final positiveSectionMatch2 = positiveSectionMatch == null
        ? RegExp(
            r'Positive\s*Aspects[:\s]*\n(.*?)(?=\n\s*(?:6\.|Recommendation|$))',
            caseSensitive: false,
            dotAll: true,
          ).firstMatch(cleaned)
        : null;
    
    final finalPositiveMatch = positiveSectionMatch ?? positiveSectionMatch2;
    if (finalPositiveMatch != null) {
      final positiveSection = finalPositiveMatch.group(1) ?? '';
      positiveAspects.addAll(_extractListItems(positiveSection));
    } else {
      final positiveSection = _extractSection(cleaned, ['Positive Aspects', 'Positive', 'Good Aspects', 'Strengths']);
      if (positiveSection.isNotEmpty) {
        positiveAspects.addAll(_extractListItems(positiveSection));
      }
    }

    // Extract recommendations
    final recommendations = <String>[];
    final recSectionMatch = RegExp(
      r'6\.\s*Recommendations[:\s]*\n(.*?)(?=\n\s*\d+\.|$)',
      caseSensitive: false,
      dotAll: true,
    ).firstMatch(cleaned);
    
    // Also try without number prefix
    final recSectionMatch2 = recSectionMatch == null
        ? RegExp(
            r'Recommendations[:\s]*\n(.*?)(?=\n\s*(?:\d+\.|$))',
            caseSensitive: false,
            dotAll: true,
          ).firstMatch(cleaned)
        : null;
    
    final finalRecMatch = recSectionMatch ?? recSectionMatch2;
    if (finalRecMatch != null) {
      final recSection = finalRecMatch.group(1) ?? '';
      recommendations.addAll(_extractListItems(recSection));
    } else {
      final recSection = _extractSection(cleaned, ['Recommendations', 'Recommendation', 'Remedies', 'Suggestions']);
      if (recSection.isNotEmpty) {
        recommendations.addAll(_extractListItems(recSection));
      }
    }

    return ParsedVastuResponse(
      overallScore: overallScore,
      directions: directions,
      rooms: rooms,
      issues: issues,
      positiveAspects: positiveAspects,
      recommendations: recommendations,
      rawText: cleaned,
    );
  }

  static String _normalizeDirection(String dir) {
    return dir
        .replaceAll('-', '')
        .replaceAll(' ', '')
        .toLowerCase()
        .replaceAll('northeast', 'Northeast')
        .replaceAll('northwest', 'Northwest')
        .replaceAll('southeast', 'Southeast')
        .replaceAll('southwest', 'Southwest')
        .replaceAll('north', 'North')
        .replaceAll('south', 'South')
        .replaceAll('east', 'East')
        .replaceAll('west', 'West');
  }

  static bool _hasIssue(String description) {
    final issueKeywords = [
      'defect',
      'dosha',
      'problem',
      'issue',
      'not ideal',
      'inauspicious',
      'should not',
      'avoid',
      'wrong',
      'bad',
      'negative',
    ];
    final lowerDesc = description.toLowerCase();
    return issueKeywords.any((keyword) => lowerDesc.contains(keyword));
  }

  static String _extractSection(String text, List<String> keywords) {
    for (var keyword in keywords) {
      // Try with numbered prefix first
      final pattern1 = RegExp(
        r'\d+\.\s*$keyword[:\s]*\n(.*?)(?=\n\s*\d+\.|$)',
        caseSensitive: false,
        dotAll: true,
      );
      final match1 = pattern1.firstMatch(text);
      if (match1 != null) {
        return match1.group(1)?.trim() ?? '';
      }
      
      // Try without numbered prefix
      final pattern2 = RegExp(
        '$keyword[:\s]*\n(.*?)(?=\n\s*(?:Overall|Directional|Room|Critical|Positive|Recommendation|\$))',
        caseSensitive: false,
        dotAll: true,
      );
      final match2 = pattern2.firstMatch(text);
      if (match2 != null) {
        return match2.group(1)?.trim() ?? '';
      }
    }
    return '';
  }

  static List<String> _extractListItems(String text) {
    final items = <String>[];
    
    // First try to match numbered list items
    final numberedPattern = RegExp(
      r'\d+\.\s*(.+?)(?=\n\s*\d+\.|$)',
      caseSensitive: false,
      dotAll: true,
    );
    
    final numberedMatches = numberedPattern.allMatches(text);
    if (numberedMatches.isNotEmpty) {
      for (var match in numberedMatches) {
        var item = match.group(1)?.trim() ?? '';
        // Remove bold markers if any
        item = item.replaceAll(RegExp(r'\*\*([^*]+)\*\*'), r'$1');
        item = item.replaceAll(RegExp(r'\*([^*]+)\*'), r'$1');
        if (item.isNotEmpty && item.length > 5) {
          items.add(item);
        }
      }
    } else {
      // Fallback to line-by-line parsing
      final lines = text.split('\n');
      
      for (var line in lines) {
        line = line.trim();
        if (line.isEmpty) continue;
        
        // Remove list markers
        line = line.replaceAll(RegExp(r'^[-•*]\s*'), '');
        line = line.replaceAll(RegExp(r'^\d+[.)]\s*'), '');
        
        // Remove bold markers if any
        line = line.replaceAll(RegExp(r'\*\*([^*]+)\*\*'), r'$1');
        line = line.replaceAll(RegExp(r'\*([^*]+)\*'), r'$1');
        
        if (line.isNotEmpty && line.length > 10) {
          items.add(line);
        }
      }
    }
    
    return items;
  }
}

class ParsedVastuResponse {
  final int overallScore;
  final List<DirectionInfo> directions;
  final List<RoomInfo> rooms;
  final List<String> issues;
  final List<String> positiveAspects;
  final List<String> recommendations;
  final String rawText;

  ParsedVastuResponse({
    required this.overallScore,
    required this.directions,
    required this.rooms,
    required this.issues,
    required this.positiveAspects,
    required this.recommendations,
    required this.rawText,
  });
}

class DirectionInfo {
  final String direction;
  final String description;
  final bool hasIssue;

  DirectionInfo({
    required this.direction,
    required this.description,
    required this.hasIssue,
  });
}

class RoomInfo {
  final String name;
  final int score; // out of 10
  final String description;

  RoomInfo({
    required this.name,
    required this.score,
    required this.description,
  });
}

