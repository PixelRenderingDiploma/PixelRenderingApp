//
//  TabBarViewController.swift
//  PixelModeling
//
//  Created by Hlib Sobolevskyi on 2024-01-31.
//

import Cocoa
import UniformTypeIdentifiers

class TabBarViewController: NSViewController {
    // MARK: Constants
    
    struct NotificationNames {
        // A notification when the tree controller's selection changes. SplitViewController uses this.
        static let selectionChanged = "selectionChangedNotification"
    }
    
    // MARK: Outlets
    
    @IBOutlet weak var outlineView: TabBarOutlineView? {
        didSet {
            // As soon the outline view loads, populate its content tree controller.
            populateOutlineContents()
        }
    }
    
    @IBOutlet weak var treeController: NSTreeController!
    // The outline view of top-level content. NSTreeController backs this.
    @objc dynamic var contents: [AnyObject] = []
    
    @Service var storageManager: StorageManagerProtocol
    @Service var syncService: SyncService
    
    private var imageDetailedViewController: ImageDetailedViewController?
    private var videoDetailedViewController: VideoDetailedViewController?
    private var threeDModelDetailedViewController: ThreeDModelDetailedViewController?
    private var folderViewController: FolderGalleryViewController?
    private var galleryViewController: ProjectsGalleryViewController?
    private var renderingViewController: RenderingViewController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        storageManager.validate()
        
        imageDetailedViewController = storyboard?.instantiateController(withIdentifier: "ImageDetailedViewController") as? ImageDetailedViewController
        imageDetailedViewController?.view.translatesAutoresizingMaskIntoConstraints = false
        
        videoDetailedViewController = storyboard?.instantiateController(withIdentifier: "VideoDetailedViewController") as? VideoDetailedViewController
        videoDetailedViewController?.view.translatesAutoresizingMaskIntoConstraints = false
        
        threeDModelDetailedViewController = storyboard?.instantiateController(withIdentifier: "ThreeDModelDetailedViewController") as? ThreeDModelDetailedViewController
        threeDModelDetailedViewController?.view.translatesAutoresizingMaskIntoConstraints = false
        
        folderViewController = storyboard?.instantiateController(withIdentifier: "FolderGalleryViewController") as? FolderGalleryViewController
        folderViewController?.view.translatesAutoresizingMaskIntoConstraints = false
        
        galleryViewController = storyboard?.instantiateController(withIdentifier: "ProjectsGalleryViewController") as? ProjectsGalleryViewController
        galleryViewController?.view.translatesAutoresizingMaskIntoConstraints = false
        
        renderingViewController = storyboard?.instantiateController(withIdentifier: "RenderingViewController") as? RenderingViewController
        renderingViewController?.view.translatesAutoresizingMaskIntoConstraints = false
        
        outlineView?.registerForDraggedTypes([.fileURL])
        outlineView?.setDraggingSourceOperationMask([.copy], forLocal: false)
        
        NotificationCenter.default.addObserver(self, selector: #selector(didDeleteProject), name: .didDeleteProjectFolder, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(refreshProjects), name: .didUserLogIn, object: nil)
    }
    
    override func viewDidAppear() {
        super.viewDidAppear()
        
        refreshProjects()
    }
    
    @objc
    private func refreshProjects() {
        Task {
            guard let cloudIDs = try? await syncService.fetchCloudProjects() else {
                return
            }
            
            let local = storageManager.getAll()
            let localIDs = Set(local.map { $0.id })
            
            for id in Set(cloudIDs).subtracting(localIDs) {
                guard let folderManager = ProjectFolderManager(with: id) else {
                    continue
                }
                
                // TODO: For now, create empty placeholder for bookmark. Consider other options
                FileManager.default.createFile(atPath: folderManager.defaultModelURL.path(), contents: nil)
                guard let bookmark = try? folderManager.defaultModelURL.bookmarkData() else {
                    continue
                }
                
                let item = StorageItem(id: id, name: id.uuidString, bookmark: bookmark)
                storageManager.insert(item)
                
                addProjectNode(id: id)
            }
            
            self.galleryViewController?.reload()
        }
    }
    
    @IBAction func importModelAction(_ sender: Any) {
        let openPanel = NSOpenPanel()
        openPanel.canChooseFiles = true
        openPanel.canChooseDirectories = false
        openPanel.allowsMultipleSelection = false
        openPanel.allowedContentTypes = [UTType(filenameExtension: "glb")!]
        openPanel.begin { [weak self] result in
            guard result == .OK, let selectedFile = openPanel.url else {
                return
            }
            
            self?.importModel(url: selectedFile)
        }
    }
    
    func importModel(url: URL) {
        print("Selected file: \(url.path)")
        
        let id = UUID()
        guard let bookmark = try? url.bookmarkData() else {
            return
        }
        
        let name = url.deletingPathExtension().lastPathComponent
        let item = StorageItem(id: id, name: name, bookmark: bookmark)
        self.storageManager.insert(item)
        self.galleryViewController?.reload()
        
        addProjectNode(id: id)
    }
    
    private func addGroupNode(_ folderName: String, identifier: String) {
        let node = Node()
        node.type = .container
        node.title = folderName
        node.identifier = identifier
    
        // Insert the group node.
        
        // Get the insertion indexPath from the current selection.
        var insertionIndexPath: IndexPath
        // If there is no selection, add a new group to the end of the content's array.
        if treeController.selectedObjects.isEmpty {
            // There's no selection, so add the folder to the top-level and at the end.
            insertionIndexPath = IndexPath(index: contents.count)
        } else {
            /** Get the index of the currently selected node, then add the number of its children to the path.
                This gives you an index that allows you to add a node to the end of the currently
                selected node's children array.
             */
            insertionIndexPath = treeController.selectionIndexPath!
            if let selectedNode = treeController.selectedObjects[0] as? Node {
                // The user is trying to add a folder on a selected folder, so add the selection to the children.
                insertionIndexPath.append(selectedNode.children.count)
            }
        }
        
        treeController.insert(node, atArrangedObjectIndexPath: insertionIndexPath)
    }
    
    private func addNode(_ node: Node, endOffset: Int = 0) {
        // Find the selection to insert the node.
        var indexPath: IndexPath
        if treeController.selectedObjects.isEmpty {
            // No selection, so just add the child to the end of the tree.
            indexPath = IndexPath(index: contents.count - endOffset)
        } else {
            // There's a selection, so insert the child at the end of the selection.
            indexPath = treeController.selectionIndexPath!
            if let node = treeController.selectedObjects[0] as? Node {
                indexPath.append(node.children.count - endOffset)
            }
        }
        
        // The child to insert has a valid URL, so use its display name as the node title.
        // Take the URL and obtain the display name (nonescaped with no extension).
        if node.isURLNode {
            node.title = node.url!.localizedName
        }
        
        // The user is adding a child node, so tell the controller directly.
        treeController.insert(node, atArrangedObjectIndexPath: indexPath)
        
        if !node.isDirectory {
            // For leaf children, select its parent for further additions.
            selectParentFromSelection()
        }
    }
    
    private func selectParentFromSelection() {
        if !treeController.selectedNodes.isEmpty {
            let firstSelectedNode = treeController.selectedNodes[0]
            if let parentNode = firstSelectedNode.parent {
                // Select the parent.
                let parentIndex = parentNode.indexPath
                treeController.setSelectionIndexPath(parentIndex)
            } else {
                // No parent exists (you are at the top of tree), so make no selection in your outline.
                let selectionIndexPaths = treeController.selectionIndexPaths
                treeController.removeSelectionIndexPaths(selectionIndexPaths)
            }
        }
    }
    
    private func addProjectsGroup() {
        // Add the Projects outline group section.
        // Note that the system shares the nodeID and the expansion restoration ID.
        
        addGroupNode(Node.NameConstants.projects, identifier: Node.projectsID)
        
        let projects = ProjectFolderManager.getProjects().compactMap { UUID(uuidString: $0.lastPathComponent) }
        for project in projects {
            addProjectNode(id: project)
        }
        
//        let separator = Node()
//        separator.type = .separator
//        addNode(separator)
        
        treeController?.setSelectionIndexPath(nil) // Start back at the root level.
    }
    
    func addProjectNode(id: UUID) {
        guard let project = ProjectFolderManager(with: id),
              let indexPath = self.indexPathOfNode(matching: { node in
                  node.identifier == Node.projectsID
              }, in: [self.treeController.arrangedObjects]) else {
            return
        }
        
        self.treeController.setSelectionIndexPath(indexPath)
        
        let node = Node()
        node.identifier = project.rootProjectFolder.lastPathComponent
        node.url = project.rootProjectFolder
        node.type = .project
        
        if let storageItem = storageManager.get(with: id),
           let url = storageItem.url {
            let modelNode = Node()
            modelNode.identifier = id.uuidString.lowercased()
            modelNode.title = url.lastPathComponent
            modelNode.url = url
            modelNode.type = .document
            
            node.children.append(modelNode)
        }
        
        addParagraphs(of: project, to: node)
        
        addNode(node)
        selectParentFromSelection()
    }
    
    private func addParagraphs(of project: ProjectFolderManager, to parent: Node) {
        for paragraph in project.paragraphs {
            let node = buildFileSystemNode(paragraph)
            node.identifier = project.rootProjectFolder.lastPathComponent + paragraph.lastPathComponent
            node.type = .projectParagraph
            
            parent.children.append(node)
        }
    }
    
    private func buildFileSystemNode(_ url: URL) -> Node {
        let node = Node()
        node.url = url
        node.identifier = url.lastPathComponent
        node.title = url.lastPathComponent
        
        if url.isFolder {
            node.type = .container
            
            let items = (try? FileManager.default.contentsOfDirectory(at: url, includingPropertiesForKeys: [], options: .skipsHiddenFiles)) ?? []
            for item in items {
                let contentNode = buildFileSystemNode(item)
                
                if item.isFolder {
                    contentNode.identifier = url.lastPathComponent + item.lastPathComponent
                }
                
                node.children.append(contentNode)
            }
        } else {
            node.type = .document
        }
        
        return node
    }
    
    private func addOtherGroup() {
        // Add the Other outline group section.
        // Note that the system shares the nodeID and the expansion restoration ID.
        
//        addGroupNode(OutlineViewController.NameConstants.places, identifier: OutlineViewController.placesID)
//        
//        // Add the Applications folder inside Places.
//        let appsURLs = FileManager.default.urls(for: .applicationDirectory, in: .localDomainMask)
//        addFileSystemObject(appsURLs[0], indexPath: IndexPath(indexes: [0, 0]))
//        
//        treeController.setSelectionIndexPath(nil) // Start back at the root level.
    }
    
    private func populateOutlineContents() {
        // Add the Places grouping and its content.
        addProjectsGroup()
        
        // Add the Pictures grouping and its outline content.
        addOtherGroup()
    }
    
    // MARK: Detail View Management
    
    // Use this to decide which view controller to use as the detail.
    func viewControllerForSelection(_ selection: [NSTreeNode]?) -> NSViewController? {
        guard let outlineViewSelection = selection else { return nil }
        
        var viewController: NSViewController?
        
        switch outlineViewSelection.count {
        case 0:
            // No selection.
            viewController = nil
        case 1:
            // A single selection.
            if let node = TabBarViewController.node(from: selection?[0] as Any) {
                if let url = node.url {
                    // The node has a URL.
                    if node.type == .project {
                        // It is project folder.
                        // TODO: think about presenting here item view on full size
                        viewController = galleryViewController
                    } else if node.type == .projectParagraph {
                        // It is project images or videos folder.
                        folderViewController?.url = node.url
                        viewController = folderViewController
                    } else if node.isDirectory {
                        // It is a folder URL.
                        viewController = galleryViewController
                    } else if let type = UTType(filenameExtension: url.pathExtension) {
                        // It is a file URL of appropriate type.
                        if type == .glb, let id = UUID(uuidString: node.identifier) {
                            threeDModelDetailedViewController?.update(with: storageManager.get(with: id))
                            threeDModelDetailedViewController?.reload()
                            viewController = threeDModelDetailedViewController
                        } else if type.conforms(to: .mpeg4Movie) {
                            videoDetailedViewController?.update(with: url)
                            videoDetailedViewController?.reload()
                            viewController = videoDetailedViewController
                        } else if type.conforms(to: .image) {
                            imageDetailedViewController?.update(with: url)
                            imageDetailedViewController?.reload()
                            viewController = imageDetailedViewController
                        }
                    }
                } else if node.type == .container {
                    viewController = galleryViewController
                } else {
                    // The node doesn't have a URL.
                    // TODO: currently handling testing rendering
                    viewController = renderingViewController
                }
            }
        default:
            // The selection is multiple or more than one.
            viewController = nil
        }

        return viewController
    }
    
    @objc
    private func didDeleteProject(_ notification: NSNotification) {
        guard let id = notification.userInfo?["id"] as? UUID,
              let indexPath = indexPathOfNode(matching: { node in
                  node.identifier == id.uuidString.lowercased()
              }, in: [treeController.arrangedObjects]) else {
            return
        }
        
        treeController.removeObject(atArrangedObjectIndexPath: indexPath)
    }
    
    func findNode(matching criteria: (Node) -> Bool, in nodes: [NSTreeNode]) -> NSTreeNode? {
        for node in nodes {
            if let model = node.representedObject as? Node, criteria(model) {
                return node
            }
            
            if let children = node.children, let found = findNode(matching: criteria, in: children) {
                return found
            }
        }
        
        return nil
    }
    
    func indexPathOfNode(matching criteria: (Node) -> Bool, in nodes: [NSTreeNode]) -> IndexPath? {
        for node in nodes {
            if let model = node.representedObject as? Node, criteria(model) {
                return node.indexPath
            }
            
            if let children = node.children, let path = indexPathOfNode(matching: criteria, in: children) {
                return path
            }
        }
        
        return nil
    }
}
